class CostoFleteSerializer < ActiveModel::Serializer
  attributes :id, :costo, :municipio
  has_one :municipio

  def municipio
		object.municipio
	end
end
