class NotaSerializer < ActiveModel::Serializer
  attributes :id, :total, :identificador, :numero_documento, :numero_comprobante, :fecha_equivalente, :estado
  has_one :cliente
  has_one :user
  has_one :tipo_factura
end
