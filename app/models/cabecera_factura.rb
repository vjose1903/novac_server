class CabeceraFactura < ApplicationRecord
  belongs_to :user
  belongs_to :cliente
end
