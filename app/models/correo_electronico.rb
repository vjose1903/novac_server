class CorreoElectronico < ApplicationRecord
  belongs_to :entidad, optional: true
end
