class TipoFacturaSerializer < ActiveModel::Serializer
  extend FastSerializer

  def self.to_hash(object, params={})
    serialize_record(object, default_fields)
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id, :referencia, :descripcion, :created_at, :updated_at, :serie, :key]
  end
end