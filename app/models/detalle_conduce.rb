class DetalleConduce < ApplicationRecord
  belongs_to :cabecera_conduce
  belongs_to :detalle_factura, optional: true
  belongs_to :articulo
end
