class IncidenciaSerializer < ActiveModel::Serializer
  extend FastSerializer

  attribute :id,                            if: Proc.new { self.get_param('id') || self.get_param('all') }
  attribute :referencia,                    if: Proc.new { self.get_param('referencia') || self.get_param('all') }
  attribute :descripcion,                   if: Proc.new { self.get_param('descripcion') || self.get_param('all') }

  def self.to_hash(object, params={})
    serialize_record(object, default_fields.select { |field| show_serialized_field?(params, field) })
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id, :referencia, :descripcion]
  end

  def get_param(col)
		return @instance_options[:"#{col}"]
	end
end