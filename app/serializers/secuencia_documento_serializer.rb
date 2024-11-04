class SecuenciaDocumentoSerializer < ActiveModel::Serializer
  attributes :id, :secuencia
  has_one :origen_secuencia
end
