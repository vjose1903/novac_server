class SuplidorSerializer < ActiveModel::Serializer

  attribute :id,                            if: Proc.new { has_to_show(self.get_param('all') || self.get_param('id')) }
  attribute :nombre,                        if: Proc.new { has_to_show(self.get_param('all') || self.get_param('nombre')) }
  attribute :telefono,                      if: Proc.new { has_to_show(self.get_param('all') || self.get_param('telefono')) }
  attribute :direccion,                     if: Proc.new { has_to_show(self.get_param('all') || self.get_param('direccion')) }
  attribute :email,                         if: Proc.new { has_to_show(self.get_param('all') || self.get_param('email')) }
  attribute :estado,                        if: Proc.new { has_to_show(self.get_param('all') || self.get_param('estado')) }
  attribute :documentos_de_identidad,       if: Proc.new { has_to_show(self.get_param('all') || self.get_param('documentos_de_identidad')) }
  attribute :nombre_completo,               if: Proc.new { has_to_show(self.get_param('all') || self.get_param('nombre_completo')) }

  def documentos_de_identidad
    optional_params = parse_serialize_optional_params(self.get_param('documentos_de_identidad'), { all: false, id: true, descripcion: true, documento: true, principal: true  })
    serialize_parser(object.documentos_de_identidad, optional_params)
  end

  def nombre_completo
		vendedor = object.nombre_completo
	end

  def get_param(col)
		return @instance_options[:"#{col}"]
	end
end
