class ConfigArticuloSerializer < ActiveModel::Serializer
  extend FastSerializer

  attribute :id,                              if: Proc.new { self.get_param('fecha_equivalente') || self.get_param('all') }
  attribute :porciento_ganancia,              if: Proc.new { self.get_param('porciento_ganancia') || self.get_param('all') }

  def self.to_hash(object, params={})
    serialize_record(object, default_fields.select { |field| show_serialized_field?(params, field) })
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id, :porciento_ganancia]
  end

  def get_param(col)
    return @instance_options[:"#{col}"]
  end
end
