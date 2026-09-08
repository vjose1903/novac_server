class PermisoSerializer < ActiveModel::Serializer
	extend FastSerializer

	def self.to_hash(object, params={}, include_acciones: nil, include_permisos_acciones: nil)
		include_acciones = params[:acciones] if include_acciones.nil? && params.respond_to?(:[])
		include_permisos_acciones = params[:permisos_acciones] if include_permisos_acciones.nil? && params.respond_to?(:[])
		data = serialize_record(object, default_fields)

		data[:acciones] = object.permisos_acciones.map { |permiso_accion| accion_to_hash(permiso_accion.accion) } if include_acciones
		data[:permisos_acciones] = object.permisos_acciones.select { |permiso_accion| permiso_accion.accion&.mostrar_front }.map { |permiso_accion| permiso_accion_to_hash(permiso_accion) } if include_permisos_acciones
		data
	end

	def self.collection_to_hash(collection, params={}, include_acciones: nil, include_permisos_acciones: nil)
		include_acciones = params[:acciones] if include_acciones.nil? && params.respond_to?(:[])
		include_permisos_acciones = params[:permisos_acciones] if include_permisos_acciones.nil? && params.respond_to?(:[])
		collection.map { |object| to_hash(object, params, include_acciones: include_acciones, include_permisos_acciones: include_permisos_acciones) }
	end

	def self.default_fields
		[:id, :descripcion, :nombre]
	end

	def self.permiso_accion_to_hash(permiso_accion)
		PermisoAccionSerializer.to_hash(permiso_accion)
	end

	def self.accion_to_hash(accion)
		return nil unless accion

		AccionSerializer.to_hash(accion, { id: true, descripcion: true, nombre: true, mostrar_front: true })
	end
	private_class_method :default_fields, :permiso_accion_to_hash, :accion_to_hash

end