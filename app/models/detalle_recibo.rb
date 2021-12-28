class DetalleRecibo < ApplicationRecord
  belongs_to :recibos_ingreso
  belongs_to :cabecera_factura, optional: true

  validates :deposito,    presence: { :message => "El recibo no esta completado." }, numericality: { greater_than: 0, :message => "El deposito del recibo debe de ser mayor a 0." }


  def self.crear_actualizar_detalle_recibo(params, padre, is_save=false)
    res = Response.new

    unless params["id"]
      detalle_recibo                            = DetalleRecibo.new
    else
      detalle_recibo                            = DetalleRecibo.find_by_id(params["id"])
    end
    
    res_valid                                   = CabeceraFactura.calculateNextBalanceFactura(params["cabecera_factura_id"], params["deposito"])
    calculo_cabecera                            = res_valid.get_data
    
    if res_valid.status_valid 
      
      detalle_recibo.balance_anterior_factura   = calculo_cabecera[:balance_anterior]
      detalle_recibo.balance_factura            = calculo_cabecera[:balance]
      detalle_recibo.is_ultimo                  = true
      detalle_recibo.pago_total                 = params["pago_total"]
      detalle_recibo.cabecera_factura_id        = params["cabecera_factura_id"]
      detalle_recibo.deposito                   = params["deposito"]
      detalle_recibo.descripcion                = params["descripcion"]
      detalle_recibo.pago_a_tiempo              = params["pago_a_tiempo"]
      
      detalle_recibo.valid?
      
      detalle_recibo.errors.delete(:recibos_ingreso) if !is_save
      
      res_valid                                 = detalle_recibo.ajustarBalanceCliente
      res_valid                                 = CabeceraFactura.payFactura(params["cabecera_factura_id"], params) if res_valid.status_valid

      if res_valid.status_valid && detalle_recibo.errors.empty? && (!is_save || (is_save && detalle_recibo.save!))
        res.set_data(detalle_recibo)
      else
        res.add_msgs(detalle_recibo.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end
      
    else
      res.add_msgs(res_valid.get_msgs)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end
    return res
  end
  
  #  --------------------------------------------------------------------------------------------------------------------------------
  
  def ajustarBalanceCliente
    res = Response.new

    cabecera_factura = self.cabecera_factura
    resultCliente = Cliente.calculateBalanceCliente(cabecera_factura.cliente_id, self.deposito, "-")
    
    if resultCliente[:error]
      res.add_msgs(resultCliente[:msg])
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end
    
    return res 
  end
  
  #  --------------------------------------------------------------------------------------------------------------------------------

  def self.validar_e_inicializar(items, padre, save)
    res_valid = Response.new
    array_valid=[]
    
    items.each do |item|
      res_temp = self.crear_actualizar_detalle_recibo(item, padre, !item[:id].nil?)

      if res_temp.status_valid
        array_valid.push(res_temp.get_data)
      else
        return res_temp 
      end
    end

    res_valid.set_data array_valid
    return res_valid
  end
end
