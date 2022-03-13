class FacturaAplicadaSerializer < ActiveModel::Serializer
  attributes :id, :total
  has_one :nota
  has_one :cabeza_factura
end
