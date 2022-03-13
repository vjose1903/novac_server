class DetalleFacturaNota < ApplicationRecord
  belongs_to :factura_aplicada
  belongs_to :articulo
  belongs_to :detalle_factura
end
