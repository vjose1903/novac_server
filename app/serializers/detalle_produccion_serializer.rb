class DetalleProduccionSerializer < ActiveModel::Serializer
  attribute :id,                                 if: Proc.new { self.get_param('id') || self.get_param('all') }
  attribute :produccion_id,                      if: Proc.new { self.get_param('produccion_id') || self.get_param('all') }
  attribute :articulo_id,                        if: Proc.new { self.get_param('articulo_id') || self.get_param('all') }
  attribute :cantidad,                           if: Proc.new { self.get_param('cantidad') || self.get_param('all') }
	attribute :cantidad_en_unidades,               if: Proc.new { self.get_param('cantidad_en_unidades') || self.get_param('all') }
	attribute :medida,                             if: Proc.new { self.get_param('medida') || self.get_param('all') }
  
	attribute :articulo,                           if: Proc.new { self.get_param('articulo') || self.get_param('all') }
  
  def articulo
    object.articulo.nombre
  end
	
  def get_param(col)
		return @instance_options[:"#{col}"]
	end
end
