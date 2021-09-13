class DetalleReciboSerializer < ActiveModel::Serializer
  attribute :id,                                               if: Proc.new { self.personalizar_parametros('id') || self.personalizar_parametros('all') }
  attribute :recibos_ingreso_id,                               if: Proc.new { self.personalizar_parametros('recibos_ingreso_id') || self.personalizar_parametros('all') }
  attribute :cabecera_factura_id,                              if: Proc.new { self.personalizar_parametros('cabecera_factura_id') || self.personalizar_parametros('all') }
  attribute :pago_total,                                       if: Proc.new { self.personalizar_parametros('pago_total') || self.personalizar_parametros('all') }
  attribute :deposito,                                         if: Proc.new { self.personalizar_parametros('deposito') || self.personalizar_parametros('all') }
  attribute :balance_factura,                                  if: Proc.new { self.personalizar_parametros('balance_factura') || self.personalizar_parametros('all') }
  attribute :balance_anterior_factura,                         if: Proc.new { self.personalizar_parametros('balance_anterior_factura') || self.personalizar_parametros('all') }
  attribute :descripcion,                                      if: Proc.new { self.personalizar_parametros('descripcion') || self.personalizar_parametros('all') }
  attribute :pago_a_tiempo,                                    if: Proc.new { self.personalizar_parametros('pago_a_tiempo') || self.personalizar_parametros('all') }
  attribute :is_ultimo,                                        if: Proc.new { self.personalizar_parametros('is_ultimo') || self.personalizar_parametros('all') }
  attribute :total_factura,                                    if: Proc.new { self.personalizar_parametros('total_factura') || self.personalizar_parametros('all') }

  def total_factura
    factura =  object.cabecera_factura
    factura["total_factura"]
  end
  
  def personalizar_parametros(col)
		return @instance_options[:"#{col}"]
	end
end
