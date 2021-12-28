class RecibosIngreso < ApplicationRecord
  belongs_to :tipo_factura
  belongs_to :user
  belongs_to :cliente
  belongs_to :vehiculo, optional: true

  
  has_many :detalle_recibos, dependent: :destroy
  attribute :detalle_recibos
  accepts_nested_attributes_for :detalle_recibos, :allow_destroy => true

  validates :total,    presence: { :message => "El recibo no esta completado." }, numericality: { greater_than: 0, :message => "El total del recibo debe de ser mayor a 0." }
  
  
  # =========================================================================================================================================================
  def self.create_update_recibo(params, is_save=false)
    RecibosIngreso.transaction do
      res = Response.new

      unless params["id"]
        recibo                     = RecibosIngreso.new()
      else
        recibo                     = RecibosIngreso.find_by_id(params["id"])
      end

      today_cuadre                 = CuadreCaja.where({ fecha_equivalente: DateTime.now.beginning_of_day..DateTime.now.end_of_day})
      
      fecha_equivalente            = params["fecha_equivalente"] ? params["fecha_equivalente"] : today_cuadre.empty? ? DateTime.now : CabeceraFactura.calculateNextDay
      
      
      recibo.user_id               = get_current_user['id']
      recibo.fecha_equivalente     = fecha_equivalente
      recibo.numero_recibo         = SecuenciaFactura.find_secuencia(17)
      recibo.cliente_id            = params["cliente_id"]
      recibo.chofer                = params["chofer"]
      recibo.total                 = params["total"]
      recibo.forma_pago            = params["forma_pago"]
      recibo.tipo_factura_id       = params["tipo_factura_id"]
      recibo.devuelta              = params["devuelta"]
      recibo.estado                = params["estado"]
      recibo.vehiculo_id           = params["vehiculo_id"]
      recibo.estado                = params["estado"]

      params["detalle_recibos"]    = params["detalle_recibos_attributes"] if params["detalle_recibos_attributes"]
      
      dependencias = [
        {modelo: DetalleRecibo, key_object: "detalle_recibos", padre: recibo},
        {modelo: Incidencia,    key_object: "incidencias",     padre: recibo}
      ]
      
      res = crear_actualizar_dependencias(dependencias, params, false) { |key_object, dependencia_data| 
        recibo.detalle_recibos   = dependencia_data if key_object == 'detalle_recibos'
        recibo.incidencias       = dependencia_data if key_object == 'incidencias'
      }

      if res.status_valid && recibo.errors.empty? && (!is_save || (is_save && recibo.save!))

        res_valid                = updateSecuencias()
        res_valid                = params.vehiculo.aumentarCantViaje                        if res_valid.status_valid && !params['vehiculo_id'].nil?

        if res_valid.status_valid

          res.set_data(serialize_parser(recibo, {all: true}))
          action = params["id"] ? 'actualizado' : 'creado'
          res.add_msg("Recibo #{action} correctamente.")
          
        else
          res.add_msgs(res_valid.get_msgs)
          res.set_status(HTTP_STATUS_CODE[:conflict])
        end

      else
        res.add_msgs(recibo.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end
      
      return res
      raise ActiveRecord::Rollback unless recibo.errors.empty? 

    end
  end

  # =========================================================================================================================================================

  def self.updateSecuencias
    res                          = Response.new
    
    secuencia_recibo             = SecuenciaFactura.find_by_id(17)
    actual                       = secuencia_recibo.secuencia
    secuencia_recibo.secuencia   = actual + 1
    
    unless secuencia_recibo.save!
      res.add_msg("Error actualizando la secuencia de los recibos.")
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # =========================================================================================================================================================
  def self.filtrarRecibos(arg, params)
    res = Response.new(params)

    recibos = RecibosIngreso
    .joins("inner join detalle_recibos on recibos_ingresos.id = detalle_recibos.recibos_ingreso_id")
    .joins("inner join cabecera_facturas on cabecera_facturas.id = detalle_recibos.cabecera_factura_id")
    .joins("inner join clientes on clientes.id = recibos_ingresos.cliente_id")
    .where("lower(recibos_ingresos.numero_recibo || ' ' || clientes.nombre || ' ' || clientes.apellido || ' ' || cabecera_facturas.numero_comprobante) like lower('%#{arg}%') AND recibos_ingresos.estado = true")
    .order("recibos_ingresos.id").to_a

    if recibos.length > 0
      puts "recibos.length > 0 ".yellow 
      res.set_data(recibos, {all: true})
    else
      res.set_data([])
      res.add_msg("No existen recibos con las especificaciones introducidas")
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end
  
  # ===================================================================================================================================================

  def self.procesoRevertirRecibo(id)
    res = { :error => false, :msg => '' }

    
    recibo_ = RecibosIngreso.find_by_id(id)

    recibo_.detalle_recibos.each do |detalle|
      resultFactura = CabeceraFactura.find_by_id(detalle["cabecera_factura_id"])

      obj = { balance: detalle["balance_anterior_factura"] }

      if resultFactura.fecha_completada
        obj["fecha_completada"] = nil
      end

      if resultFactura.pagada
        obj["pagada"] = false
      end

      unless resultFactura.update(obj)
        render json: resultFactura.errors, status: 400
      end

      resultCliente = Cliente.calculateBalanceCliente(recibo_["cliente_id"], detalle["deposito"], "+")

      if resultCliente[:error]
        res = { :error => true, :msg => resultCliente[:msg] }
      end
    end
    
    if recibo_["vehiculo_id"]
      vehiculo = Vehiculo.find_by_id(recibo_["vehiculo_id"])
      
      unless vehiculo.update({ cantidad_viajes: vehiculo.cantidad_viajes - 1 })
        res = { :error => true, :msg => vehiculo.errors }
      end
    end
    
    unless recibo_.destroy
      res = { :error => true, :msg => recibo_.errors }
    end

    return res
  end

  # ===================================================================================================================================================
  def self.get_last_recibos(cant)
    recibos = []
    recibos = RecibosIngreso.all.order('id DESC').limit(cant)
    return recibos
  end

  # ===================================================================================================================================================
  def self.get_last_recibo_of_cabecera_factura(id_cabecera)
    select_ = "SELECT dr.id, is_ultimo, recibos_ingreso_id, ri.cliente_id as cliente_id"
    from_ = "FROM detalle_recibos dr"
    joins_ = "inner join recibos_ingresos ri on ri.id = dr.recibos_ingreso_id"
    where_ = "WHERE cabecera_factura_id=#{id_cabecera}"
    order_ = "ORDER BY dr.created_at DESC"
    limit_ = "LIMIT 1"

    query = "#{select_} #{from_} #{joins_} #{where_} #{order_} #{limit_}"
    return my_query(query)
  end

  # ========================================================================================================================

  def self.parsearData(data)
    begin
      obj                    = data.attributes
      obj["cliente"]         = serialize_parser(data.cliente, {documentos_de_identidad: true, nombre: true, apellido: true, direccion: true, balance: true})
      obj["user"]            = serialize_parser(data.user,    {nombre: true, apellido: true})

    rescue
      obj = data
    end

    detalles = []
    data.detalle_recibos.to_a.each do |detalle|
      objD = detalle.attributes
      factura = CabeceraFactura.find_by_id(detalle["cabecera_factura_id"])

      objD["total_factura"] = factura["total_factura"]
      detalles.push(objD)
    end

    if data.chofer
      chofer_ = User.find_by_id(data.chofer)
      chofer_ = serialize_parser(chofer_, {id:true, nombre: true, apellido: true, documentos_de_identidad: true,})
    end

    obj["chofer"] = chofer_
    obj["detalle_recibos"] = detalles

    

    return obj
  end
end
