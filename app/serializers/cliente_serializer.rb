class ClienteSerializer < ActiveModel::Serializer
  include FastSerializer

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
    vendedor = object.vendedor
    return nil unless vendedor

    serialize_record(vendedor, [:nombre, :apellido, :vendedor_id, :nombre_completo], readers: {
      nombre: ->(user) { user.nombre.capitalize },
      apellido: ->(user) { user.apellido.capitalize },
      vendedor_id: ->(user) { user.id },
      nombre_completo: ->(user) { user.nombre_completo }
    })
  end

  def nombre_completo
    vendedor = object.nombre_completo
  end

  def documentos_de_identidad
    object.documentos_de_identidad.map do |documento|
      serialize_selected_record(documento, [:id, :descripcion, :documento, :principal], param: self.get_param('documentos_de_identidad'), include_all: self.get_param('all'))
    end
  end

  def provincia_id
    object.provincia&.id
  end

  def provincia
    provincia = object.provincia
    return nil unless provincia

    serialize_selected_record(provincia, [:id, :nombre, :codigo], param: self.get_param('provincia'), include_all: self.get_param('all'))
  end

  def municipio
    municipio = object.municipio
    return nil unless municipio

    serialize_selected_record(municipio, [:id, :nombre, :codigo], param: self.get_param('municipio'), include_all: self.get_param('all'))
  end

  def get_param(col)
    return @instance_options[:"#{col}"]
  end

end
