class TipoFactura < ApplicationRecord
	has_one :secuencia_factura
	has_one :secuencia_comprobante
end
