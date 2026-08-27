class UserSerializer < ActiveModel::Serializer

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
    data = {}

    data[:id] = object.id if show_field?(params, :id)
    data[:nombre] = object.nombre.capitalize if show_field?(params, :nombre)
    data[:usuario] = object.usuario if show_field?(params, :usuario)
    data[:estado] = object.estado if show_field?(params, :estado)
    data[:apellido] = object.apellido.capitalize if show_field?(params, :apellido)
    data[:sexo] = object.sexo if show_field?(params, :sexo)
    data[:telefono] = object.telefono if show_field?(params, :telefono)
    data[:email] = object.email if show_field?(params, :email)
    data[:fecha_nacimiento] = formatearFecha(object.fecha_nacimiento.to_s, TipoFecha.sin_hora) if show_field?(params, :fecha_nacimiento)
    data[:role] = object.role if show_field?(params, :role)
    data[:imagen] = object.imagen.as_json if show_field?(params, :imagen)
    data[:sign_in_count] = object.sign_in_count if show_field?(params, :sign_in_count)
    data[:documentos_de_identidad] = documentos_de_identidad_to_hash(object) if show_field?(params, :documentos_de_identidad)
    data[:roles] = roles_to_hash(object) if params[:roles]
    data[:permisos] = object.get_permisos.as_json(only: [:permiso_accion_id, :permiso]) if params[:permisos]
    data[:nombre_completo] = object.nombre_completo

    data
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.show_field?(params, key)
    params[:all] || params[key]
  end

  def self.documentos_de_identidad_to_hash(object)
    object.documentos_de_identidad.map do |documento|
      {
        id: documento.id,
        descripcion: documento.descripcion,
        documento: documento.documento,
        principal: documento.principal
      }
    end
  end

  def self.roles_to_hash(object)
    object.roles.map do |role|
      {
        id: role.id,
        descripcion: role.descripcion,
        nombre: role.nombre
      }
    end
  end
end

