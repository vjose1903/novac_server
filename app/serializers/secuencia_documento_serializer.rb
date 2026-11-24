class SecuenciaDocumentoSerializer < ActiveModel::Serializer
end

class SecuenciaDocumentoSerializer
  extend FastSerializer
  extend ActiveModelSerializerFastAdapter

  def self.default_fields
    [:id, :secuencia, :origen_secuencia]
  end

  def origen_secuencia
    fast_serialize_parser(object.origen_secuencia, { all: true })
  end
end
