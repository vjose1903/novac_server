class ContenidoArticuloSerializer < ActiveModel::Serializer
  attribute :id,                         if: Proc.new { self.personalizar_parametros('id') || self.personalizar_parametros('all') }
  attribute :articulo_id,                if: Proc.new { self.personalizar_parametros('articulo_id') || self.personalizar_parametros('all') }
  attribute :referencia,                 if: Proc.new { self.personalizar_parametros('referencia') || self.personalizar_parametros('all') }
  attribute :costo,                      if: Proc.new { self.personalizar_parametros('costo') || self.personalizar_parametros('all') }
  attribute :precio,                     if: Proc.new { self.personalizar_parametros('precio') || self.personalizar_parametros('all') }
  attribute :cantidad,                   if: Proc.new { self.personalizar_parametros('cantidad') || self.personalizar_parametros('all') }
  attribute :medida,                     if: Proc.new { self.personalizar_parametros('medida') || self.personalizar_parametros('all') }
  attribute :condicion,                  if: Proc.new { self.personalizar_parametros('condicion') || self.personalizar_parametros('all') }
  attribute :calcular_itbis,             if: Proc.new { self.personalizar_parametros('calcular_itbis') || self.personalizar_parametros('all') }

  def calcular_itbis
    object.calcular_itbis || false
  end

  def personalizar_parametros(col)
    return @instance_options[:"#{col}"]
  end
end
