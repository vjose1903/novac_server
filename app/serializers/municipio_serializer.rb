class MunicipioSerializer < ActiveModel::Serializer

  attribute :id,          if: Proc.new { self.get_param('all') || has_to_show(self.get_param('id')) }
  attribute :nombre,      if: Proc.new { self.get_param('all') || has_to_show(self.get_param('nombre')) }
  attribute :codigo,      if: Proc.new { self.get_param('all') || has_to_show(self.get_param('codigo')) }
  attribute :provincia,   if: Proc.new { has_to_show(self.get_param('provincia')) }

  def provincia
    optional_params = parse_serialize_optional_params(self.get_param('provincia'), { all: false, id: true, nombre: true  })
    serialize_parser(object.provincia, optional_params)
  end

  def get_param(col)
    @instance_options[:"#{col}"]
  end

end
