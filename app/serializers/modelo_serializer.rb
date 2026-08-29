class ModeloSerializer < ActiveModel::Serializer
  extend FastSerializer

  attributes :id, :marca_id, :descripcion, :created_at, :updated_at, :marca

  def marca
    MarcaSerializer.to_hash(object.marca)
  end

  def self.to_hash(object, params={})
    fields = default_fields.dup
    fields.insert(-2, :marca_descripcion) if object.respond_to?(:has_attribute?) && object.has_attribute?(:marca_descripcion)

    serialize_record(object, fields, readers: {
      marca_descripcion: ->(modelo) { modelo.read_attribute(:marca_descripcion) },
      marca: ->(modelo) { MarcaSerializer.to_hash(modelo.marca) }
    })
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id, :marca_id, :descripcion, :created_at, :updated_at, :marca]
  end
end
