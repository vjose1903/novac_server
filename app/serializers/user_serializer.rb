class UserSerializer < ActiveModel::Serializer
  extend FastSerializer

  attribute :id,                        if: Proc.new { self.get_param('id') || self.get_param('all') }
  attribute :nombre,                    if: Proc.new { self.get_param('nombre') || self.get_param('all') }
  attribute :usuario,                   if: Proc.new { self.get_param('usuario') || self.get_param('all') }
  attribute :estado,                    if: Proc.new { self.get_param('estado') || self.get_param('all') }
  attribute :apellido,                  if: Proc.new { self.get_param('apellido') || self.get_param('all') }
  attribute :sexo,                      if: Proc.new { self.get_param('sexo') || self.get_param('all') }
  # attribute :fotoPerfil,                if: Proc.new { self.get_param('fotoPerfil') || self.get_param('all') }
  attribute :telefono,                  if: Proc.new { self.get_param('telefono') || self.get_param('all') }
  attribute :email,                     if: Proc.new { self.get_param('email') || self.get_param('all') }
  attribute :fecha_nacimiento,          if: Proc.new { self.get_param('fecha_nacimiento') || self.get_param('all') }
  attribute :role,                      if: Proc.new { self.get_param('role') || self.get_param('all') }
  attribute :imagen,                    if: Proc.new { self.get_param('imagen') || self.get_param('all') }
  attribute :sign_in_count,             if: Proc.new { self.get_param('sign_in_count') || self.get_param('all') }
  attribute :documentos_de_identidad,   if: Proc.new { self.get_param('documentos_de_identidad') || self.get_param('all') }

  attribute :roles,                     if: Proc.new { self.get_param('roles')  }
  attribute :permisos,                  if: Proc.new { self.get_param('permisos')  }
  attribute :nombre_completo

  # def fotoPerfil
  #   nil
  # end

  def fecha_nacimiento
    formatearFecha(object.fecha_nacimiento.to_s, TipoFecha.sin_hora)
  end

  def nombre
    object.nombre.capitalize
  end

  def apellido
    object.apellido.capitalize
  end

  def documentos_de_identidad
    optional_params = parse_serialize_optional_params(self.get_param('documentos_de_identidad'), { all: false, id: true, descripcion: true, documento: true, principal: true  })
    serialize_parser(object.documentos_de_identidad, optional_params)
  end

  def nombre_completo
    object.nombre_completo
  end

  def roles
    roles = serialize_parser(object.roles, {id: true, descripcion: true, nombre: true})
    roles
  end

  def permisos
    object.get_permisos
  end

  def get_param(col)
    return @instance_options[:"#{col}"]
  end

  def self.to_hash(object, params={})
    readers = {
      nombre: ->(user) { user.nombre.capitalize },
      apellido: ->(user) { user.apellido.capitalize },
      fecha_nacimiento: ->(user) { formatearFecha(user.fecha_nacimiento.to_s, TipoFecha.sin_hora) },
      imagen: ->(user) { user.imagen.as_json },
      documentos_de_identidad: ->(user) { documentos_de_identidad_to_hash(user) }
    }
    data = serialize_record(object, default_fields.select { |field| show_serialized_field?(params, field) }, readers: readers)
    data[:roles] = roles_to_hash(object) if params[:roles]
    data[:permisos] = object.get_permisos.as_json(only: [:permiso_accion_id, :permiso]) if params[:permisos]
    data[:nombre_completo] = object.nombre_completo

    data
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [
      :id,
      :nombre,
      :usuario,
      :estado,
      :apellido,
      :sexo,
      :telefono,
      :email,
      :fecha_nacimiento,
      :role,
      :imagen,
      :sign_in_count,
      :documentos_de_identidad
    ]
  end

  def self.documentos_de_identidad_to_hash(object)
    serialize_collection(object.documentos_de_identidad, [:id, :descripcion, :documento, :principal])
  end

  def self.roles_to_hash(object)
    serialize_collection(object.roles, [:id, :descripcion, :nombre])
  end
end
