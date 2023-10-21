class PagoFacturaDetalle < ApplicationRecord
  belongs_to :pago_factura
  belongs_to :cabecera_factura, optional: true

	validates :deposito,    presence: { :message => "El pago no esta completado." }, numericality: { greater_than: 0, :message => "El deposito del pago debe de ser mayor a 0." }


  def self.crear_actualizar_detalle_pago(params, padre, is_save=false)
    res = Response.new

    detalle_pago                                = PagoFacturaDetalle.where(:id => params[:id]).first_or_create

    res_valid                                   = CabeceraFactura.calculateNextBalanceFactura(params[:cabecera_factura_id], params[:deposito])
    calculo_cabecera                            = res_valid.get_data

    if res_valid.status_valid
      detalle_pago.cabecera_factura_id        = params[:cabecera_factura_id]
      detalle_pago.balance_anterior_factura   = calculo_cabecera[:balance_anterior]
      detalle_pago.balance_factura            = calculo_cabecera[:balance]
      detalle_pago.deposito                   = params[:deposito] > calculo_cabecera[:balance_anterior] ? calculo_cabecera[:balance_anterior] : params[:deposito]
      detalle_pago.is_ultimo                  = true
      detalle_pago.descripcion                = params[:descripcion]
      detalle_pago.pago_a_tiempo              = params[:pago_a_tiempo]

      detalle_pago.valid?

      detalle_pago.errors.delete(:pago_facturas) if !is_save

      res_valid                                 = detalle_pago.set_last_pago_no_ultimo
      res_valid                                 = CabeceraFactura.payFactura(params["cabecera_factura_id"], params) if res_valid.status_valid

      if res_valid.status_valid && detalle_pago.errors.empty? && (!is_save || (is_save && detalle_pago.save!))
        res.set_data(detalle_pago)
      else
        res.add_msgs(res_valid.get_msgs.to_a)
        res.add_msgs(detalle_pago.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

    else
      res.add_msgs(res_valid.get_msgs.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end
    return res
    transaction_rollback if !detalle_pago.errors.empty? || !res.status_valid
  end

  #  --------------------------------------------------------------------------------------------------------------------------------

  def set_last_pago_no_ultimo
    res = Response.new

    last_pago = PagoFacturaDetalle.get_last_pago_by_cabecera_factura(self.cabecera_factura_id)

    if !last_pago.nil? && !last_pago.update({ is_ultimo: false })
      res.add_msgs(last_pago.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end


  #  --------------------------------------------------------------------------------------------------------------------------------

  def self.get_last_pago_by_cabecera_factura(id_cabecera)

    last_pago = PagoFacturaDetalle
    .joins("inner join pago_facturas on pago_facturas.id = pago_factura_detalles.pago_factura_id")
    .where("pago_factura_detalles.cabecera_factura_id=#{id_cabecera} and pago_factura_detalles.is_ultimo = true")
    .order("pago_factura_detalles.created_at DESC")
    .limit(1)

    return last_pago[0]
  end

  #  --------------------------------------------------------------------------------------------------------------------------------

  def self.validar_e_inicializar(items, padre, save)
    res_valid       = Response.new
    array_valid     = []

    items.each do |item|
      res_temp      = self.crear_actualizar_detalle_pago(item, padre, !item[:id].nil?)

      if res_temp.status_valid
        respuesta   = res_temp.get_data
        array_valid.push(res_temp.get_data)
      else
        return res_temp
      end
    end

    res_valid.set_data object_valid
    return res_valid
  end
end
