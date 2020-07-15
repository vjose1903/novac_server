class HistoricoArticulo < ApplicationRecord
  belongs_to :articulo
  belongs_to :suplidor
  belongs_to :marca
  belongs_to :modelo
  belongs_to :tipo_articulo
end
