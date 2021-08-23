class Telefono < ApplicationRecord
  belongs_to :entidad, optional: true
end
