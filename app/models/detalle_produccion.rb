class DetalleProduccion < ApplicationRecord
  belongs_to :produccion
  belongs_to :articulo

  attribute :articulo
end
