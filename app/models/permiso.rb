class Permiso < ApplicationRecord
	has_many :permisos_acciones
	has_many :acciones, through: :permisos_acciones

	def self.models_includes
		includes = [{permisos_acciones: [:permiso, :accion]}, :acciones]
    return includes
	end

	def self.get_all
		Permiso.all.where({mostrar_front: true}).includes(Permiso.models_includes)
	end

	def self.verificateUserPermiso( user_id, permiso_descripcion )
		res         = Response.new
		permiso     = Permiso.find_by_descripcion(permiso_descripcion)

		if permiso != nil

			joins_  = "INNER JOIN roles_permisos_acciones on roles_permisos_acciones.role_id = roles.id"
			joins_ += " INNER JOIN users_roles on users_roles.role_id = roles.id"
			joins_ += " INNER JOIN permisos_acciones on permisos_acciones.id = roles_permisos_acciones.permiso_accion_id"
			joins_ += " INNER JOIN permisos on permisos.id = permisos_acciones.permiso_id"

			role                    = Role.joins(joins_).select("roles.nombre, roles.id").where("permisos.id = #{permiso.id} AND users_roles.user_id = #{user_id}").group("roles.id")

			if role.length == 0
				res.add_msg("Usuario no tiene los permisos de: #{permiso_descripcion}.")
				res.set_status(HTTP_STATUS_CODE[:conflict])
			else
				res.set_data({has_permiso: true})
			end


		else
			res.add_msg("permiso no encontrado.")
			res.set_status(HTTP_STATUS_CODE[:conflict])
		end

		return res

	end

end
