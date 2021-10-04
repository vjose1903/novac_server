class FormulasProductosTerminadoSerializer < ActiveModel::Serializer
  attribute :id,                        if: Proc.new { self.personalizar_parametros('id') || self.personalizar_parametros('all') }
  attribute :articulo_id,               if: Proc.new { self.personalizar_parametros('articulo_id') || self.personalizar_parametros('all') }
  attribute :cantidad,                  if: Proc.new { self.personalizar_parametros('cantidad') || self.personalizar_parametros('all') }
  attribute :costo,                     if: Proc.new { self.personalizar_parametros('costo') || self.personalizar_parametros('all') }
  attribute :articulo_combo,            if: Proc.new { self.personalizar_parametros('articulo_combo') || self.personalizar_parametros('all') }
  attribute :precio,                    if: Proc.new { self.personalizar_parametros('precio') || self.personalizar_parametros('all') }

  

  def personalizar_parametros(col)
    return @instance_options[:"#{col}"]
  end
end
