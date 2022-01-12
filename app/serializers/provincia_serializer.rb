class ProvinciaSerializer < ActiveModel::Serializer
  attributes :id, :nombre

  attribute :municipios, if: Proc.new { self.get_param('municipios') }

  def get_param(col)
		return @instance_options[:"#{col}"]
	end
end
