class Accion < ApplicationRecord
	has_one :permiso, :through => :permisos_acciones
end
