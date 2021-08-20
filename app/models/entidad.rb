class Entidad < ApplicationRecord
  belongs_to :user

  has_many :telefonos, dependent: :destroy
  has_many :correos_electronicos, dependent: :destroy

end
