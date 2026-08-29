class CostoFleteSerializer < ActiveModel::Serializer
  extend FastSerializer

  attributes :id, :costo, :municipio, :municipio_id
  has_one :municipio

  def self.to_hash(object, params={})
    serialize_record(object, [:id, :costo, :municipio, :municipio_id], readers: {
      municipio: ->(costo_flete) { MunicipioSerializer.to_hash(costo_flete.municipio, params) }
    })
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def municipio
		object.municipio
	end
end
