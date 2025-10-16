class DetalleReciboSerializer < ActiveModel::Serializer
  attribute :id,                                               if: Proc.new { self.get_param('id') || self.get_param('all') }
  attribute :recibos_ingreso_id,                               if: Proc.new { self.get_param('recibos_ingreso_id') || self.get_param('all') }
  attribute :cabecera_factura_id,                              if: Proc.new { self.get_param('cabecera_factura_id') || self.get_param('all') }
  attribute :pago_total,                                       if: Proc.new { self.get_param('pago_total') || self.get_param('all') }
  attribute :deposito,                                         if: Proc.new { self.get_param('deposito') || self.get_param('all') }
  attribute :mora,                                             if: Proc.new { self.get_param('mora') || self.get_param('all') }
  attribute :balance_factura,                                  if: Proc.new { self.get_param('balance_factura') || self.get_param('all') }
  attribute :balance_anterior_factura,                         if: Proc.new { self.get_param('balance_anterior_factura') || self.get_param('all') }
  attribute :descripcion,                                      if: Proc.new { self.get_param('descripcion') || self.get_param('all') }
  attribute :pago_a_tiempo,                                    if: Proc.new { self.get_param('pago_a_tiempo') || self.get_param('all') }
  attribute :is_ultimo,                                        if: Proc.new { self.get_param('is_ultimo') || self.get_param('all') }
  attribute :total_factura,                                    if: Proc.new { self.get_param('total_factura') || self.get_param('all') }

  def total_factura
    factura =  object.cabecera_factura
    factura["total_factura"]
  end

  def get_param(col)
		return @instance_options[:"#{col}"]
	end
end
