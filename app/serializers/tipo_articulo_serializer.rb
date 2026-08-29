class TipoArticuloSerializer < ActiveModel::Serializer
  extend FastSerializer

  def self.to_hash(object, params={})
    serialize_record(object, default_fields.select { |field| show_serialized_field?(params, field) })
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id, :descripcion, :created_at, :updated_at, :tipo, :codigo]
  end
end