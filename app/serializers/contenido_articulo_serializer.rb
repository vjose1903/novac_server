class ContenidoArticuloSerializer < ActiveModel::Serializer
  extend FastSerializer


  def self.to_hash(object, params={})
    fields = default_fields.select { |field| show_serialized_field?(params, field) }
    serialize_record(object, fields, readers: { calcular_itbis: ->(item) { read_serialized_value(item, :calcular_itbis) || false } })
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id, :articulo_id, :referencia, :costo, :precio, :cantidad, :medida, :condicion, :calcular_itbis]
  end


end
