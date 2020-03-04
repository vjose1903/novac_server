class DetalleFactura < ApplicationRecord
  belongs_to :cabecera_factura
  belongs_to :articulo
end
