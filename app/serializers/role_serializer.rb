class RoleSerializer < ActiveModel::Serializer
	extend FastSerializer

	def self.to_hash(object, params={}, include_permisos_acciones: nil)
		include_permisos_acciones = params[:permisos_acciones] if include_permisos_acciones.nil? && params.respond_to?(:[])
		fields = params.empty? ? default_fields : default_fields.select { |field| show_serialized_field?(params, field) }
		data = serialize_record(object, fields)

		data[:permisos_acciones] = object.permisos_acciones.map { |permiso_accion| permiso_accion_to_hash(permiso_accion) } if include_permisos_acciones
		data
	end

	def self.collection_to_hash(collection, params={}, include_permisos_acciones: nil)
		include_permisos_acciones = params[:permisos_acciones] if include_permisos_acciones.nil? && params.respond_to?(:[])
		collection.map { |object| to_hash(object, params, include_permisos_acciones: include_permisos_acciones) }
	end

	def self.default_fields
		[:id, :descripcion, :nombre, :ruta_defecto, :estado]
	end

	def self.permiso_accion_to_hash(permiso_accion)
		PermisoAccionSerializer.to_hash(permiso_accion)
	end
	private_class_method :default_fields, :permiso_accion_to_hash

end