class UserSerializer < ActiveModel::Serializer
  extend FastSerializer

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
    DocumentoDeIdentidadSerializer.collection_to_hash(object.documentos_de_identidad, { all: true })
  end

  def self.roles_to_hash(object)
    RoleSerializer.collection_to_hash(object.roles, { id: true, descripcion: true, nombre: true })
  end
end
