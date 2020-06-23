class DetalleConduce < ApplicationRecord
  belongs_to :cabecera_conduce
  belongs_to :detalle_factura
  belongs_to :articulo
end
