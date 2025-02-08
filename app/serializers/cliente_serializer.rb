class ClienteSerializer < ActiveModel::Serializer
  attribute :id,                                 if: Proc.new { self.get_param('all') ||  has_to_show(self.get_param('id'))}
  attribute :imagen_id,                          if: Proc.new { self.get_param('all') ||  has_to_show(self.get_param('imagen_id'))}
  attribute :nombre,                             if: Proc.new { self.get_param('all') ||  has_to_show(self.get_param('nombre'))}
  attribute :estado,                             if: Proc.new { self.get_param('all') ||  has_to_show(self.get_param('estado'))}
  attribute :apellido,                           if: Proc.new { self.get_param('all') ||  has_to_show(self.get_param('apellido'))}
  attribute :limite_credito,                     if: Proc.new { self.get_param('all') ||  has_to_show(self.get_param('limite_credito'))}
  attribute :telefono,                           if: Proc.new { self.get_param('all') ||  has_to_show(self.get_param('telefono'))}
  attribute :direccion,                          if: Proc.new { self.get_param('all') ||  has_to_show(self.get_param('direccion'))}
  attribute :sexo,                               if: Proc.new { self.get_param('all') ||  has_to_show(self.get_param('sexo'))}
  attribute :maximo_credito,                     if: Proc.new { self.get_param('all') ||  has_to_show(self.get_param('maximo_credito'))}
  attribute :vendedor_id,                        if: Proc.new { self.get_param('all') ||  has_to_show(self.get_param('vendedor_id'))}
  attribute :balance,                            if: Proc.new { self.get_param('all') ||  has_to_show(self.get_param('balance'))}
  attribute :municipio_id,                       if: Proc.new { self.get_param('all') ||  has_to_show(self.get_param('municipio_id'))}
  
  attribute :vendedor,                           if: Proc.new { self.get_param('all') ||  has_to_show(self.get_param('vendedor'))}
  attribute :nombre_completo
  attribute :documentos_de_identidad,            if: Proc.new { self.get_param('all') ||  has_to_show(self.get_param('documentos_de_identidad'))}
  attribute :provincia_id,                       if: Proc.new { self.get_param('all') ||  has_to_show(self.get_param('provincia_id'))}
  attribute :provincia,                          if: Proc.new { self.get_param('all') ||  has_to_show(self.get_param('provincia'))}
  attribute :municipio,                          if: Proc.new { self.get_param('all') ||  has_to_show(self.get_param('municipio'))}


  def vendedor
    vendedor = User.find_by_id(object.vendedor_id)
    serialize_parser(vendedor, {nombre: true, apellido: true, vendedor_id: true })
  end

  def nombre_completo
    vendedor = object.nombre_completo
  end

  def documentos_de_identidad
    serialize_parser(object.documentos_de_identidad, {all: true})
  end

  def provincia_id
    object.provincia&.id
  end

  def provincia
    optional_params = parse_serialize_optional_params(self.get_param('provincia'), { all: false, id: true, nombre: true, codigo: true })
    serialize_parser(object.provincia, optional_params)
  end

  def municipio
    optional_params = parse_serialize_optional_params(self.get_param('municipio'), { all: false, id: true, nombre: true, codigo: true })
    serialize_parser(object.municipio, optional_params)
  end

  def get_param(col)
    return @instance_options[:"#{col}"]
  end
end
