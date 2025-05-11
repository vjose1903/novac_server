class EcfReceptionSerializer < ActiveModel::Serializer
  attributes :id, :eNCF, :rnc_emisor, :rnc_comprador, :monto_total
end
