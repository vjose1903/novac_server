class DetalleFacturaNotaSerializer < ActiveModel::Serializer
  attributes :id, :unidad, :cantidad, :cantidad_en_unidades, :itbis, :costo, :precio, :total, :descuento
  has_one :factura_aplicada
  has_one :articulo
  has_one :detalle_factura
end
