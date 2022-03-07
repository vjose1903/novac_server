class Permiso < ApplicationRecord
	has_many :permisos_acciones
	has_many :acciones, through: :permisos_acciones
end
