class DetalleRecibo < ApplicationRecord
  belongs_to :recibos_ingreso
  belongs_to :cabecera_factura, optional: true

  validate  :has_payment

  def self.crear_actualizar_detalle_recibo(params, padre, is_save=false)
    res = Response.new

    detalle_recibo                              = DetalleRecibo.where(:id => params[:id]).first_or_create

    res_valid                                   = CabeceraFactura.calculateNextBalanceFactura(params[:cabecera_factura_id], params[:deposito])
    calculo_cabecera                            = res_valid.get_data

    if res_valid.status_valid
      detalle_recibo.balance_anterior_factura   = calculo_cabecera[:balance_anterior]
      detalle_recibo.balance_factura            = calculo_cabecera[:balance]
      detalle_recibo.is_ultimo                  = true
      detalle_recibo.pago_total                 = params[:pago_total]
      detalle_recibo.cabecera_factura_id        = params[:cabecera_factura_id]
      detalle_recibo.deposito                   = params[:deposito]
      detalle_recibo.mora                       = params[:mora]
      detalle_recibo.descripcion                = params[:descripcion]
      detalle_recibo.pago_a_tiempo              = params[:pago_a_tiempo]

      detalle_recibo.valid?

      detalle_recibo.errors.delete(:recibos_ingreso) if !is_save

      res_valid                                 = detalle_recibo.ajustarBalanceCliente(params)
      res_valid                                 = detalle_recibo.set_last_recibo_no_ultimo                         if res_valid.status_valid
      res_valid                                 = CabeceraFactura.payFactura(params[:cabecera_factura_id], params) if res_valid.status_valid

      if res_valid.status_valid && detalle_recibo.errors.empty? && (!is_save || (is_save && detalle_recibo.save!))
        res.set_data({:devolucion => {:monto => calculo_cabecera[:devolucion], :numero_comprobante => calculo_cabecera[:factura]['numero_comprobante'], :factura_id => calculo_cabecera[:factura]['id'] }, :detalle => detalle_recibo})
      else
        res.add_msgs(res_valid.get_msgs.to_a)
        res.add_msgs(detalle_recibo.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

    else
      res.add_msgs(res_valid.get_msgs)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end
    return res
    raise ActiveRecord::Rollback if !detalle_recibo.errors.empty? || !res.status_valid
  end

  #  --------------------------------------------------------------------------------------------------------------------------------

  def set_last_recibo_no_ultimo
    res = Response.new

    last_recibo = DetalleRecibo.get_last_recibo_by_cabecera_factura(self.cabecera_factura_id)

    if !last_recibo.nil? && !last_recibo.update({ is_ultimo: false })
      res.add_msgs(last_recibo.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end


  #  --------------------------------------------------------------------------------------------------------------------------------

  def self.get_last_recibo_by_cabecera_factura(id_cabecera)

    last_recibo = DetalleRecibo
    .joins("inner join recibos_ingresos on recibos_ingresos.id = detalle_recibos.recibos_ingreso_id")
    .where("detalle_recibos.cabecera_factura_id=#{id_cabecera} and detalle_recibos.is_ultimo = true")
    .order("detalle_recibos.created_at DESC")
    .limit(1)

    return last_recibo[0]
  end
  #  --------------------------------------------------------------------------------------------------------------------------------

  def ajustarBalanceCliente(params)
    res = Response.new

    cabecera_factura = self.cabecera_factura
    resultCliente    = Cliente.calculate_balance_cliente(cabecera_factura.cliente_id, params[:deposito], "-", true)

    unless resultCliente.status_valid
      res.add_msg(resultCliente.get_msgs.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  #  --------------------------------------------------------------------------------------------------------------------------------

  def self.validar_e_inicializar(items, padre, save)
    res_valid       = Response.new
    object_valid    = {:detalles => [], :devoluciones => []}

    items.each do |item|
      res_temp      = self.crear_actualizar_detalle_recibo(item, padre, !item[:id].nil?)

      if res_temp.status_valid
        respuesta   = res_temp.get_data
        object_valid[:devoluciones].push(respuesta[:devolucion]) if respuesta[:devolucion][:monto] > 0
        object_valid[:detalles].push(respuesta[:detalle])
      else
        return res_temp
      end
    end

    res_valid.set_data object_valid
    return res_valid
  end

  private 

  def has_payment
    payment = (self.deposito || 0 ) + (self.mora || 0)
    if payment == 0 
      errors.add(:has_payment, "El deposito del recibo debe de ser mayor a 0.")
    end
  end
end
