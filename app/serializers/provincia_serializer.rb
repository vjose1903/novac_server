class ProvinciaSerializer < ActiveModel::Serializer
  attributes :id, :nombre

  attribute :municipios, if: Proc.new { self.personalizar_parametros('municipios') }

  def personalizar_parametros(col)
		return @instance_options[:"#{col}"]
	end
end
