class Role < ApplicationRecord
  has_and_belongs_to_many :users, :join_table => :users_roles

	has_many :roles_permisos_acciones,           dependent: :destroy
	has_many :permisos_acciones, through: :roles_permisos_acciones

  scopify

	validates :nombre,      presence: { :message => "Debe de especificar un nombre para el rol." },       uniqueness: { scope: [:activo, :descripcion], case_sensitive: false, :message => "Este rol ya esta creado."}, :if => :activo
	validates :descripcion, presence: { :message => "Debe de especificar una descripcion para el rol." }

  def self.create_update_role(params)
    res = Response.new

    unless params["id"]
      role = Role.new
    else
      role = Role.find_by_id(params["id"])
    end

    role.nombre         = params["nombre"]
    role.descripcion    = params["descripcion"]
    role.ruta_defecto   = params["ruta_defecto"] || nil
    role.activo         = params["activo"]

    role.valid?

    params["roles_permisos_acciones"]  = []

		params["permisos_acciones"].each do | item |
			params["roles_permisos_acciones"].push({"role_id": nil, "permiso_accion_id": item})
			puts "item ".red + "#{item.to_json}"
			puts " "
		end
		puts "params[roles_permisos_acciones] ".yellow + "(#{params["roles_permisos_acciones"].to_json})"

		dependencias = [
			{modelo: RolPermisoAccion, key_object: "roles_permisos_acciones", padre: role},
		]

		res = crear_actualizar_dependencias(dependencias, params, false) { |key_object, dependencia_data|
			role.roles_permisos_acciones   = dependencia_data if key_object == 'roles_permisos_acciones'
		}

		if res.status_valid && role.errors.empty? && role.valid? && role.save!
      action = params["id"] ? 'actualizado' : 'creado'
			res.add_msg("Rol #{action} correctamente.")
      res.set_data(role)
    else
      res.add_msgs(role.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end
end
