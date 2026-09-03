class ClienteSerializer < ActiveModel::Serializer
  include FastSerializer
  extend FastSerializer

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
    self.class.documentos_de_identidad_to_hash(object, self.get_param('documentos_de_identidad'), self.get_param('all'))
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

  def self.to_hash(object, params={})
    readers = {
      vendedor: ->(cliente) { vendedor_to_hash(cliente.vendedor) },
      nombre_completo: ->(cliente) { cliente.nombre_completo },
      documentos_de_identidad: ->(cliente) { documentos_de_identidad_to_hash(cliente, params[:documentos_de_identidad], params[:all]) },
      provincia_id: ->(cliente) { cliente.provincia&.id },
      provincia: ->(cliente) { provincia_to_hash(cliente.provincia, params[:provincia], params[:all]) },
      municipio: ->(cliente) { municipio_to_hash(cliente.municipio, params[:municipio], params[:all]) }
    }
    serialize_record(object, default_fields.select { |field| show_serialized_field?(params, field) }, readers: readers)
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [
      :id,
      :imagen_id,
      :nombre,
      :estado,
      :apellido,
      :limite_credito,
      :telefono,
      :direccion,
      :sexo,
      :maximo_credito,
      :vendedor_id,
      :balance,
      :municipio_id,
      :vendedor,
      :nombre_completo,
      :documentos_de_identidad,
      :provincia_id,
      :provincia,
      :municipio
    ]
  end

  def self.vendedor_to_hash(vendedor)
    return nil unless vendedor

    serialize_record(vendedor, [:nombre, :apellido, :vendedor_id, :nombre_completo], readers: {
      nombre: ->(user) { user.nombre.capitalize },
      apellido: ->(user) { user.apellido.capitalize },
      vendedor_id: ->(user) { user.id },
      nombre_completo: ->(user) { user.nombre_completo }
    })
  end

  def self.documentos_de_identidad_to_hash(object, param=true, include_all=false)
    fields = selected_serialized_fields(param, DocumentoDeIdentidadSerializer.default_fields, include_all: include_all)
    fields_params = fields.each_with_object({ all: false }) { |field, hash| hash[field] = true }
    DocumentoDeIdentidadSerializer.collection_to_hash(object.documentos_de_identidad, fields_params)
  end

  def self.provincia_to_hash(provincia, param=true, include_all=false)
    return nil unless provincia

    ProvinciaSerializer.to_hash(provincia, { id: true, nombre: true, codigo: true })
  end

  def self.municipio_to_hash(municipio, param=true, include_all=false)
    return nil unless municipio

    MunicipioSerializer.to_hash(municipio, { all: true })
  end

end
