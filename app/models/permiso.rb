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

end
