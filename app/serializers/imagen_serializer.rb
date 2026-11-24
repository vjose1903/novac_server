class ImagenSerializer < ActiveModel::Serializer
end

class ImagenSerializer
  extend FastSerializer
  extend ActiveModelSerializerFastAdapter

  def self.default_fields
    [:id, :file_name, :base_64]
  end
end
