class MunicipioSerializer < ActiveModel::Serializer
  extend FastSerializer




  def self.to_hash(object, params={})
    readers = {
      provincia: ->(municipio) { provincia_to_hash(municipio.provincia, params[:provincia]) }
    }

    serialize_record(object, selected_fields(params), readers: readers)
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id, :nombre, :codigo]
  end

  def self.selected_fields(params={})
    fields = default_fields.select { |field| show_serialized_field?(params, field) }
    fields << :provincia if has_to_show(params[:provincia])
    fields
  end

  def self.provincia_to_hash(provincia, param=nil)
    return nil unless provincia

    fields = selected_serialized_fields(param, [:id, :nombre])
    params = fields.each_with_object({}) { |field, h| h[field] = true }
    ProvinciaSerializer.to_hash(provincia, params)
  end
end
