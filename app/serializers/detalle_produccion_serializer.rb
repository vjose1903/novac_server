class DetalleProduccionSerializer < ActiveModel::Serializer
  attribute :id,                                 if: Proc.new { self.personalizar_parametros('id') || self.personalizar_parametros('all') }
  attribute :produccion_id,                      if: Proc.new { self.personalizar_parametros('produccion_id') || self.personalizar_parametros('all') }
  attribute :articulo_id,                        if: Proc.new { self.personalizar_parametros('articulo_id') || self.personalizar_parametros('all') }
  attribute :cantidad,                           if: Proc.new { self.personalizar_parametros('cantidad') || self.personalizar_parametros('all') }
	attribute :cantidad_en_unidades,               if: Proc.new { self.personalizar_parametros('cantidad_en_unidades') || self.personalizar_parametros('all') }
	attribute :medida,                             if: Proc.new { self.personalizar_parametros('medida') || self.personalizar_parametros('all') }
  
	attribute :articulo,                           if: Proc.new { self.personalizar_parametros('articulo') || self.personalizar_parametros('all') }
  
  def articulo
    object.articulo.nombre
  end
	
  def personalizar_parametros(col)
		return @instance_options[:"#{col}"]
	end
end
