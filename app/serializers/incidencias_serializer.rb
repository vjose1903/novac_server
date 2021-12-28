class IncidenciasSerializer < ActiveModel::Serializer
  attribute :id,                            if: Proc.new { self.personalizar_parametros('id') || self.personalizar_parametros('all') }
  attribute :referencia,                    if: Proc.new { self.personalizar_parametros('referencia') || self.personalizar_parametros('all') }
  attribute :descripcion,                   if: Proc.new { self.personalizar_parametros('descripcion') || self.personalizar_parametros('all') }
  

  def personalizar_parametros(col)
		return @instance_options[:"#{col}"]
	end
end
