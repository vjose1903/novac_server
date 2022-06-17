class RecibosIngreso < ApplicationRecord
  belongs_to :tipo_factura
  belongs_to :user
  belongs_to :cliente

  has_many :detalle_recibos, dependent: :destroy

  has_many :incidencias, :as => :origen, dependent: :destroy, class_name: "Incidencia"
  has_many :camiones_viajes, :as => :origen, dependent: :destroy, class_name: "CamionViaje"
  has_many :choferes_viajes, dependent: :destroy

  validates :total,    presence: { :message => "El recibo no esta completado." }, numericality: { greater_than: 0, :message => "El total del recibo debe de ser mayor a 0." }

  # =========================================================================================================================================================

	def self.models_includes
		includes = [
			{user: :documentos_de_identidad},
			{cliente: :documentos_de_identidad},
			:tipo_factura,
			{detalle_recibos: [:recibos_ingreso, :cabecera_factura]},
			{choferes_viajes: [{user: :documentos_de_identidad}]}
		]
		return includes
	end

  # =========================================================================================================================================================
  def self.create_update_recibo(params, is_save=false)
    res                            = Response.new
    RecibosIngreso.transaction do

			recibo                       = RecibosIngreso.where(:id => params["id"]).first_or_create

      today_cuadre                 = CuadreCaja.where({ fecha_equivalente: DateTime.now.beginning_of_day..DateTime.now.end_of_day})

      fecha_equivalente            = params["fecha_equivalente"] ? params["fecha_equivalente"] : today_cuadre.empty? ? DateTime.now : CabeceraFactura.calculateNextDay


      recibo.user_id               = get_current_user['id']
      recibo.fecha_equivalente     = fecha_equivalente
      recibo.numero_recibo         = SecuenciaFactura.find_secuencia(17)
      recibo.cliente_id            = params["cliente_id"]
      recibo.forma_pago            = params["forma_pago"]
      recibo.tipo_factura_id       = params["tipo_factura_id"]
      recibo.estado                = params["estado"]
      recibo.estado                = params["estado"]

      recibo.devuelta              = params["devuelta"]
      recibo.total                 = params["total"]

			recibo.valid?


      dependencias = [
        {modelo: DetalleRecibo,  key_object: "detalle_recibos",  padre: recibo},
        {modelo: Incidencia,     key_object: "incidencias",      padre: recibo},
        {modelo: ChoferViaje,     key_object: "choferes_viajes",  padre: recibo},
        {modelo: CamionViaje,    key_object: "camiones_viajes",  padre: recibo},
      ]

      devoluciones = []

      res = crear_actualizar_dependencias(dependencias, params, false) { |key_object, dependencia_data|
        recibo.detalle_recibos   = dependencia_data[:detalles]      if key_object == 'detalle_recibos'
        devoluciones             = dependencia_data[:devoluciones]  if key_object == 'detalle_recibos'
        recibo.incidencias       = dependencia_data                 if key_object == 'incidencias'
        recibo.camiones_viajes   = dependencia_data                 if key_object == 'camiones_viajes'
        recibo.choferes_viajes   = dependencia_data                 if key_object == 'choferes_viajes'
      }

      if res.status_valid
        total_por_detalle          = recibo.detalle_recibos.map { |item| item.deposito }
        total_calculado            = total_por_detalle.inject { |item, acu| item + acu }

        recibo.devuelta            = params["total"] - total_calculado
        recibo.total               = total_calculado

        if recibo.errors.empty? && (!is_save || (is_save && recibo.save!))

          res_valid                = updateSecuencias(17)

          if res_valid.status_valid
            data = {"recibo": serialize_parser(recibo, {all: true}) }
            data = { **data, "devoluciones": devoluciones } unless devoluciones.blank?

            res.set_data(data)
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
      end

      raise ActiveRecord::Rollback if !recibo.errors.empty? || !res.status_valid
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
    .group("recibos_ingresos.id")
    .order("recibos_ingresos.id DESC")

    if recibos.length > 0
      res.set_data(recibos, {all: true}, RecibosIngreso.models_includes)
    else
      cantidad_registros = RecibosIngreso.where({estado: true}).count
      res.add_msg(cantidad_registros == 0 ? "No existen recibos de ingresos registrados." : "No existen recibos con las especificaciones introducidas")
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # ===================================================================================================================================================

  def self.puedeAnular(params)
    res                 = Response.new
    last_cuadre         = CuadreCaja.all.last

    last_recibo         = DetalleRecibo.get_last_recibo_by_cabecera_factura(params["id"])
    recibo_id           = params["tipo"] === "by_factura" ? last_recibo.recibos_ingreso_id : params["id"]
    @recibo_a_anular    = RecibosIngreso.find_by_id(recibo_id)

    if !@recibo_a_anular.nil?
      if last_cuadre.nil? || comparar_fecha(@recibo_a_anular.fecha_equivalente.to_s, last_cuadre[:created_at].to_s, ">=")

        if params["tipo"] === 'by_factura'
          if last_recibo.nil? || (!last_recibo.nil? && !last_recibo.is_ultimo)
            res.add_msg("Solo puede anular el último recibo realizado a esta factura.")
            res.set_status(HTTP_STATUS_CODE[:conflict])
          end
        elsif params["tipo"] === 'by_id'
          unless @recibo_a_anular.detalle_recibos.all? { |detalle| detalle.is_ultimo }
            res.add_msg("Solo puede anular el último recibo realizado a una factura, este recibo contiene una o varias facturas que tienen recibos mas recientes.")
            res.set_status(HTTP_STATUS_CODE[:conflict])
          end
        end

      else
        res.add_msg("El recibo no puede ser anulado, por que no es del dia de hoy.")
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end
    else
      res.add_msg("Error buscando el recibo de ingreso solicitado.")
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # ===================================================================================================================================================

  def self.revertirRecibo(params)
    res                   = Response.new
    RecibosIngreso.transaction do

      res_valid           = RecibosIngreso.puedeAnular(params)
      if res_valid.status_valid
        res_valid         = @recibo_a_anular.procesoRevertirRecibo

        if res_valid.status_valid && @recibo_a_anular.destroy
          msg             = params["tipo"] === "by_factura" ? "Ultima transacción revertida correctamente." : "Recibo de ingreso anulado correctamente."
          res.add_msg(msg)
        else
          res.add_msgs(res_valid.get_msgs)
          res.set_status(HTTP_STATUS_CODE[:conflict])
        end

      else
        res.add_msgs(res_valid.get_msgs)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      raise ActiveRecord::Rollback unless res.status_valid
    end

    return res
  end



  # ===================================================================================================================================================

  def procesoRevertirRecibo
    res_valid     = Response.new

    self.detalle_recibos.each  do |item|
      res_temp    = RecibosIngreso.revertirReciboDetalle(item, self)
      return res_temp unless res_temp.status_valid
    end

    self.camiones_viajes.each do |camion_viaje|
      res_temp    = camion_viaje.vehiculo.ajustarCantViaje("-")
      return res_temp unless res_temp.status_valid
    end


    return res_valid
  end

  # ===================================================================================================================================================

  def self.revertirReciboDetalle(detalle, recibo)
    res = Response.new

    cabecera_factura = detalle.cabecera_factura

    obj                       = { balance: detalle["balance_anterior_factura"] }
    obj["fecha_completada"]   = nil   if cabecera_factura.fecha_completada
    obj["pagada"]             = false if cabecera_factura.pagada

    if cabecera_factura.update(obj)

      resultCliente           = Cliente.calculate_balance_cliente(recibo.cliente_id, detalle["deposito"], "+")
      unless resultCliente.status_valid
        res.add_msg(resultCliente.get_msgs.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

    else
      res.add_msgs(cabecera_factura.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end
end
