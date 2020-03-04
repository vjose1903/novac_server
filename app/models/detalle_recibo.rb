class DetalleRecibo < ApplicationRecord
  belongs_to :recibos_ingreso
  belongs_to :cabecera_factura
end
