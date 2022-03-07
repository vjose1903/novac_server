class MunicipioSerializer < ActiveModel::Serializer
  attributes :id, :nombre, :provincia
  has_one :provincia

  def provincia
		serialize_parser(object.provincia, {all: true})
	end

end
