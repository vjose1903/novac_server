class AccionSerializer < ActiveModel::Serializer
	extend FastSerializer

	attribute :id,                     if: Proc.new { self.get_param('id') || self.get_param('all') }
	attribute :descripcion,            if: Proc.new { self.get_param('descripcion') || self.get_param('all') }
	attribute :nombre,                 if: Proc.new { self.get_param('nombre') || self.get_param('all') }
	attribute :mostrar_front,          if: Proc.new { self.get_param('mostrar_front') || self.get_param('all') }


	def get_param(col)
		return @instance_options[:"#{col}"]
	end

	def self.to_hash(object)
		serialize_record(object, default_fields)
	end

	def self.collection_to_hash(collection)
		serialize_collection(collection, default_fields)
	end

	def self.default_fields
		[:id, :descripcion, :nombre, :mostrar_front]
	end
end
