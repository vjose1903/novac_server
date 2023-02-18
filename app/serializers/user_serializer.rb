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
    serialize_parser(object.documentos_de_identidad, {all: true})
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
end


