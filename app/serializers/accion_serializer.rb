class AccionSerializer < ActiveModel::Serializer
	extend FastSerializer




	def self.to_hash(object, params={})
		fields = params.empty? ? default_fields : default_fields.select { |field| show_serialized_field?(params, field) }
		serialize_record(object, fields)
	end

	def self.collection_to_hash(collection, params={})
		collection.map { |object| to_hash(object, params) }
	end

	def self.default_fields
		[:id, :nombre, :descripcion, :metodo, :created_at, :updated_at, :mostrar_front]
	end
end
