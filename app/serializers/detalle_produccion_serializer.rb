class DetalleProduccionSerializer < ActiveModel::Serializer
  extend FastSerializer

  

  def self.to_hash(object, params={})
    serialize_record(object, default_fields.select { |field| show_serialized_field?(params, field) }, readers: {
      articulo: ->(detalle) { detalle.articulo.nombre }
    })
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id, :produccion_id, :articulo_id, :cantidad, :cantidad_en_unidades, :medida, :articulo]
  end

	
end
