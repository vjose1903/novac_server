class RolPermisoAccion < ApplicationRecord
  belongs_to :role
  belongs_to :permiso_accion
end
