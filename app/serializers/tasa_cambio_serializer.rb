class TasaCambioSerializer < ActiveModel::Serializer
  extend FastSerializer

  attribute :id,                       if: Proc.new { self.get_param('id')                   || self.get_param('all') }
  attribute :divisa_id,                if: Proc.new { self.get_param('divisa_id')            || self.get_param('all') }
  attribute :valor,                    if: Proc.new { self.get_param('valor')                || self.get_param('all') }
  attribute :fecha_equivalente,        if: Proc.new { self.get_param('fecha_equivalente')    || self.get_param('all') }


	def get_param(col)
		return @instance_options[:"#{col}"]
	end

  def self.to_hash(object, params={})
    serialize_record(object, default_fields.select { |field| show_serialized_field?(params, field) })
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id, :divisa_id, :valor, :fecha_equivalente]
  end
end
