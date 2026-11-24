class NombreBancoSerializer < ActiveModel::Serializer
end

class NombreBancoSerializer
  extend FastSerializer
  extend ActiveModelSerializerFastAdapter

  def self.default_fields
    [:id, :nombre, :identificador]
  end
end
