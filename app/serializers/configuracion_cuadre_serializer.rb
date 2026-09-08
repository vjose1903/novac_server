class ConfiguracionCuadreSerializer < ActiveModel::Serializer
  extend FastSerializer


  def self.to_hash(object, params={})
    serialize_record(object, default_fields.select { |field| show_serialized_field?(params, field) }, readers: {
      config: ->(configuracion_cuadre) { parse_config(read_serialized_value(configuracion_cuadre, :config)) }
    })
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id, :config, :created_at, :updated_at]
  end

  def self.parse_config(value)
    value.is_a?(String) ? (JSON.parse(value) rescue {}) : value
  end


end
