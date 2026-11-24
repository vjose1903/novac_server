class TipoCuentaBancariaSerializer < ActiveModel::Serializer
end

class TipoCuentaBancariaSerializer
  extend FastSerializer
  extend ActiveModelSerializerFastAdapter

  def self.default_fields
    [:id, :descripcion, :estado]
  end
end
