class DetalleRecibo < ApplicationRecord
  belongs_to :cabecera_recibo
  belongs_to :trabajo
  belongs_to :cabecera_factura
end
