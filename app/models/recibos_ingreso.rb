class RecibosIngreso < ApplicationRecord
  belongs_to :tipo_factura
  belongs_to :user
  belongs_to :cliente
  belongs_to :vehiculo, optional: true

  has_many :detalle_recibos, dependent: :destroy
  attribute :detalle_recibos
  accepts_nested_attributes_for :detalle_recibos, :allow_destroy => true

  attribute :vehiculo
  attribute :user
  attribute :cliente
  attribute :tipo_factura
  attribute :detalle_recibos
  
  # =========================================================================================================================================================

  def self.filtrarRecibos(arg)
    arg = arg === " " ? "" : arg
    select_ = "SELECT r.id"
    from_ = "FROM recibos_ingresos r"
    joins_ = "inner join detalle_recibos dr on r.id = dr.recibos_ingreso_id
              inner join cabecera_facturas cf on cf.id = dr.cabecera_factura_id
              inner join clientes c on c.id = r.cliente_id"
    where_ = "where lower(r.numero_recibo || ' ' || c.nombre || ' ' || c.apellido || ' ' || cf.numero_comprobante) like lower('%#{arg}%') AND r.estado = true"
    order_ = "ORDER BY r.id DESC"
    group_ = "GROUP BY r.id"

    query = "#{select_} #{from_} #{joins_} #{where_} #{group_} #{order_}"

    my_query(query)
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

      resultCliente = Cliente.CalculateBalanceCLiente(recibo_["cliente_id"], detalle["deposito"], "+")

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

  # ===================================================================================================================================================
  def self.find_secuencia
    actual_secuencia_recibo = SecuenciaFactura.find_by_tipo_factura_id(17)

    if actual_secuencia_recibo == [] || actual_secuencia_recibo == nil
      next_secuencia_recibo = 1
    else
      next_secuencia_recibo = actual_secuencia_recibo["secuencia"] + 1
    end

    numero_secuencia = ("%05d" % next_secuencia_recibo)

    return numero_secuencia
  end
  # ========================================================================================================================

  def self.parsearData(data)
    begin
      obj = data.attributes
      obj["detalle_recibos"] = data.detalle_recibos.to_a
      obj["cliente"] = data.cliente
      obj["user"] = data.user
    rescue
      obj = data
    end

    detalles = []
    obj["detalle_recibos"].each do |detalle|
      objD = detalle.attributes
      factura = CabeceraFactura.find_by_id(detalle["cabecera_factura_id"])

      objD["total_factura"] = factura["total_factura"]
      detalles.push(objD)
    end

    if data.chofer
      chofer_ = User.find_by_id(data.chofer)
    end

    obj["chofer"] = chofer_
    obj["detalle_recibos"] = detalles

    return obj
  end
end
