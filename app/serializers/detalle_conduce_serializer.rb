class DetalleConduceSerializer < ActiveModel::Serializer
  attribute :id,                                 if: Proc.new { self.personalizar_parametros('id') || self.personalizar_parametros('all') }
  attribute :cabecera_conduce_id,                if: Proc.new { self.personalizar_parametros('cabecera_conduce_id') || self.personalizar_parametros('all') }
  attribute :detalle_factura_id,                 if: Proc.new { self.personalizar_parametros('detalle_factura_id') || self.personalizar_parametros('all') }
  attribute :articulo_id,                        if: Proc.new { self.personalizar_parametros('articulo_id') || self.personalizar_parametros('all') }
  attribute :cantidad,                           if: Proc.new { self.personalizar_parametros('cantidad') || self.personalizar_parametros('all') }
  attribute :unidad,                             if: Proc.new { self.personalizar_parametros('unidad') || self.personalizar_parametros('all') }

  def personalizar_parametros(col)
		return @instance_options[:"#{col}"]
	end
end
