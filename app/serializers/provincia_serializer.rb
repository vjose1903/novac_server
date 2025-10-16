class ProvinciaSerializer < ActiveModel::Serializer
  attribute :id,          if: Proc.new { self.get_param('all') || has_to_show(self.get_param('id')) }
  attribute :nombre,      if: Proc.new { self.get_param('all') || has_to_show(self.get_param('nombre')) }
  attribute :codigo,      if: Proc.new { self.get_param('all') || has_to_show(self.get_param('codigo')) }
  attribute :municipios,  if: Proc.new { self.get_param('all') || has_to_show(self.get_param('municipios')) }

  def municipios
    optional_params = parse_serialize_optional_params(self.get_param('municipios'), { all: false, id: true, nombre: true, codigo: true  })
    serialize_parser(object.municipios, optional_params)
  end

  def get_param(col)
		return @instance_options[:"#{col}"]
	end
end
