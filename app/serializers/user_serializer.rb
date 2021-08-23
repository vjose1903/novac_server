class UserSerializer < ActiveModel::Serializer

  attribute :id,                        if: Proc.new { self.personalizar_parametros('id') || self.personalizar_parametros('all') }
  attribute :nombre,                    if: Proc.new { self.personalizar_parametros('nombre') || self.personalizar_parametros('all') }
  attribute :usuario,                   if: Proc.new { self.personalizar_parametros('usuario') || self.personalizar_parametros('all') }
  attribute :estado,                    if: Proc.new { self.personalizar_parametros('estado') || self.personalizar_parametros('all') }
  attribute :cedula,                    if: Proc.new { self.personalizar_parametros('cedula') || self.personalizar_parametros('all') }
  attribute :apellido,                  if: Proc.new { self.personalizar_parametros('apellido') || self.personalizar_parametros('all') }
  attribute :sexo,                      if: Proc.new { self.personalizar_parametros('sexo') || self.personalizar_parametros('all') }
  attribute :fotoPerfil,                if: Proc.new { self.personalizar_parametros('fotoPerfil') || self.personalizar_parametros('all') }
  attribute :telefono,                  if: Proc.new { self.personalizar_parametros('telefono') || self.personalizar_parametros('all') }
  attribute :email,                     if: Proc.new { self.personalizar_parametros('email') || self.personalizar_parametros('all') }
  attribute :fecha_nacimiento,          if: Proc.new { self.personalizar_parametros('fecha_nacimiento') || self.personalizar_parametros('all') }
  attribute :role,                      if: Proc.new { self.personalizar_parametros('role') || self.personalizar_parametros('all') }
  attribute :imagen,                    if: Proc.new { self.personalizar_parametros('imagen') || self.personalizar_parametros('all') }
  attribute :documentos_de_identidad,   if: Proc.new { self.personalizar_parametros('documentos_de_identidad') || self.personalizar_parametros('all') }

  attribute :vendedor_id,               if: Proc.new { self.personalizar_parametros('vendedor_id')  }

  def nombre
    object.nombre.capitalize
  end

  def apellido
    object.apellido.capitalize
  end

  def documentos_de_identidad
    serialize_parser(documentos_de_identidad, {})
  end
  
  def vendedor_id
    object.id
  end

  def personalizar_parametros(col)
		return @instance_options[:"#{col}"]
	end
end


