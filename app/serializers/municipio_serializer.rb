class MunicipioSerializer < ActiveModel::Serializer
  attributes :id, :nombre, :provincia
  has_one :provincia

  def provincia
		ActiveModelSerializers::SerializableResource.new(object.provincia, {})
	end

end
