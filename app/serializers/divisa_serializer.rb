class DivisaSerializer < ActiveModel::Serializer
  extend FastSerializer





  def self.to_hash(object, params={})
    readers = {
      imagen: ->(divisa) { divisa.imagenes.first&.as_json }
    }
    serialize_record(object, default_fields.select { |field| show_serialized_field?(params, field) }, readers: readers)
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id, :nombre, :simbolo, :code, :is_principal, :estado, :current_tasa, :imagen]
  end
end
