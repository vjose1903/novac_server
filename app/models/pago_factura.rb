class PagoFactura < ApplicationRecord
  belongs_to :user
  belongs_to :suplidor
  belongs_to :tipo_factura

  has_many :pago_factura_detalles, dependent: :destroy
  validates :total,    presence: { :message => 'El pago no esta completado.' }, numericality: { greater_than: 0, :message => 'El total del pago debe de ser mayor a 0.' }

	# =========================================================================================================================================================

  def self.models_includes
    includes = [
      {user: :documentos_de_identidad},
      {suplidor: :documentos_de_identidad},
      :tipo_factura,
      {pago_factura_detalles: [:pago_factura, :cabecera_factura]},
    ]
    return includes
  end

	# =========================================================================================================================================================
	def self.create_update(params, is_save=false)
    res                          = Response.new
    PagoFactura.transaction do

      @tipo_factura_id           = TipoFacturaManagement.get_by_key(TiposFacturasKey.pago_factura)&.id

			pago                       = PagoFactura.where(:id => params[:id]).first_or_create

      today_cuadre               = CuadreCaja.where({ fecha_equivalente: DateTime.now.beginning_of_day..DateTime.now.end_of_day})

      fecha_equivalente          = params[:fecha_equivalente] ? params[:fecha_equivalente] : today_cuadre.empty? ? DateTime.now : CabeceraFactura.calculateNextDay


      pago.user_id               = get_current_user[:id]
      pago.suplidor_id           = params[:suplidor_id]
      pago.tipo_factura_id       = params[:tipo_factura_id]
      pago.fecha_equivalente     = fecha_equivalente
      pago.numero                = SecuenciaFactura.find_secuencia(@tipo_factura_id)
      pago.forma_pago            = params[:forma_pago]

			pago.valid?
      pago.errors.delete(:total)

      dependencias = [ {modelo: PagoFacturaDetalle,  key_object: 'pago_factura_detalles',  padre: pago} ]

      res = crear_actualizar_dependencias(dependencias, params) { |key_object, dependencia_data|
        pago.pago_factura_detalles = dependencia_data      if key_object == 'pago_factura_detalles'
      }

      if res.status_valid
        total_por_detalle          = pago.pago_factura_detalles.map { |item| item.deposito }
        total_calculado            = total_por_detalle.inject { |item, acu| item + acu }

        pago.total                 = total_calculado
				pago.valid?

        if pago.errors.empty? && (!is_save || (is_save && pago.save!))

          result                = updateSecuencias(@tipo_factura_id)

          if result.status_valid
            res.set_data(serialize_parser(pago, {all: true}))
            action = params[:id] ? 'actualizado' : 'creado'
            res.add_msg("Pago factura #{action} correctamente.")

          else
            res.add_msgs(result.get_msgs.to_a)
            res.set_status(HTTP_STATUS_CODE[:conflict])
          end

        else
          res.add_msgs(pago.errors.to_a)
          res.set_status(HTTP_STATUS_CODE[:conflict])
        end
      end

      transaction_rollback if !pago.errors.empty? || !res.status_valid
    end

    return res
  end

	# =========================================================================================================================================================
  def self.filtrarPagos(arg, params)
    res = Response.new(params)

    pagos = PagoFactura
    .joins('inner join pago_factura_detalles on pago_facturas.id = pago_factura_detalles.pago_factura_id')
    .joins('inner join cabecera_facturas on cabecera_facturas.id = pago_factura_detalles.cabecera_factura_id')
    .joins('inner join suplidores on suplidores.id = pago_facturas.suplidor_id')
    .where("lower(pago_facturas.numero || ' ' || suplidores.nombre || ' ' || cabecera_facturas.numero_comprobante) like lower('%#{arg}%') AND pago_facturas.estado = true")
    .group('pago_facturas.id')
    .order('pago_facturas.id DESC')

    if pagos.length > 0
      res.set_data(pagos, {all: true}, PagoFactura.models_includes)
    else
      cantidad_registros = PagoFactura.where({estado: true}).count
      res.add_msg(cantidad_registros == 0 ? 'No existen pagos de facturas registrados.' : 'No existen pagos de facturas con las especificaciones introducidas.')
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # ===================================================================================================================================================

  def self.puedeAnular(params)
    res                 = Response.new
    last_cuadre         = CuadreCaja.all.last

    last_pago           = PagoFacturaDetalle.get_last_pago_by_cabecera_factura(params[:id])
    pago_id             = params[:tipo] === 'by_factura' ? last_pago.pago_factura_id : params[:id]
    @pago_a_anular      = PagoFactura.find_by_id(pago_id)

    if !@pago_a_anular.nil?
      if last_cuadre.nil? || comparar_fecha(@pago_a_anular.fecha_equivalente.to_s, last_cuadre[:created_at].to_s, '>=')

        if params[:tipo] === 'by_factura'
          if last_pago.nil? || (!last_pago.nil? && !last_pago.is_ultimo)
            res.add_msg('Solo puede anular el último pago realizado a esta factura.')
            res.set_status(HTTP_STATUS_CODE[:conflict])
          end
        elsif params[:tipo] === 'by_id'
          unless @pago_a_anular.pago_factura_detalles.all? { |detalle| detalle.is_ultimo }
            res.add_msg('Solo puede anular el último pago realizado a una factura, este pago contiene una o varias facturas que tienen pagos mas recientes.')
            res.set_status(HTTP_STATUS_CODE[:conflict])
          end
        end

      else
        res.add_msg('El pago no puede ser anulado, por que no es del dia de hoy.')
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end
    else
      res.add_msg('Error buscando el pago de ingreso solicitado.')
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # ===================================================================================================================================================

	def self.revertirPago(params)
    res                   = Response.new
    PagoFactura.transaction do

      res_valid           = PagoFactura.puedeAnular(params)
      if res_valid.status_valid
        res_valid         = @pago_a_anular.procesoRevertirPago

        if res_valid.status_valid && @pago_a_anular.destroy
          msg             = params[:tipo] === 'by_factura' ? 'Ultima transacción revertida correctamente.' : 'Pago de factura anulado correctamente.'
          res.add_msg(msg)
        else
          res.add_msgs(res_valid.get_msgs.to_a)
          res.set_status(HTTP_STATUS_CODE[:conflict])
        end

      else
        res.add_msgs(res_valid.get_msgs.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      transaction_rollback unless res.status_valid
    end

    return res
  end

  # ===================================================================================================================================================

	def procesoRevertirPago
    res_valid     = Response.new

    self.pago_factura_detalles.each  do |item|
      res_temp    = PagoFactura.revertirPagoDetalle(item, self)
      return res_temp unless res_temp.status_valid
    end

    return res_valid
  end

  # ===================================================================================================================================================

	def self.revertirPagoDetalle(detalle, recibo)
    res = Response.new

    cabecera_factura = detalle.cabecera_factura

    obj                       = { balance: detalle['balance_anterior_factura'] }
    obj['fecha_completada']   = nil   if cabecera_factura.fecha_completada
    obj['pagada']             = false if cabecera_factura.pagada

    unless cabecera_factura.update(obj)
      res.add_msgs(cabecera_factura.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # ===================================================================================================================================================
end
