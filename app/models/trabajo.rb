class Trabajo < ApplicationRecord
  belongs_to :cliente
  belongs_to :marca
  belongs_to :modelo
end
