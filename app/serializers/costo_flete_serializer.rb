class CostoFleteSerializer < ActiveModel::Serializer
  attributes :id, :costo, :municipio, :municipio_id
  has_one :municipio

  def municipio
		object.municipio
	end
end
