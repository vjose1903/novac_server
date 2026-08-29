class ConfiguracionCuadreSerializer < ActiveModel::Serializer
  extend FastSerializer

  attribute :id,             if: Proc.new { self.get_param('all') || has_to_show(self.get_param('id')) }
  attribute :config,         if: Proc.new { self.get_param('all') || has_to_show(self.get_param('config')) }
  attribute :created_at,     if: Proc.new { self.get_param('all') || has_to_show(self.get_param('created_at')) }
  attribute :updated_at,     if: Proc.new { self.get_param('all') || has_to_show(self.get_param('updated_at')) }

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

  def config
    parse_config(object.config)
  end

  def get_param(col)
    return @instance_options[:"#{col}"]
  end
end
