class CabeceraRecibo < ApplicationRecord
  belongs_to :user
  belongs_to :cliente
end
