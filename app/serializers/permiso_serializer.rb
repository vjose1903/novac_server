class PermisoSerializer < ActiveModel::Serializer
	extend FastSerializer

  attributes :id, :descripcion, :nombre
  attribute :acciones,                        if: Proc.new { self.get_param('acciones')}
  attribute :permisos_acciones,               if: Proc.new { self.get_param('permisos_acciones')}

		def acciones
			acciones = if object.association(:permisos_acciones).loaded?
				object.permisos_acciones.map(&:accion)
			else
				object.acciones
			end

			acciones.map { |accion| serialize_accion(accion) }
		end

		def permisos_acciones
			permisos_acciones = if object.association(:permisos_acciones).loaded?
				object.permisos_acciones.select { |permiso_accion| permiso_accion.accion&.mostrar_front }
			else
				object.permisos_acciones.joins(:accion).includes(:accion).where(accion: { mostrar_front: true })
			end

			permisos_acciones.map { |permiso_accion| serialize_permiso_accion(permiso_accion) }
		end

		def get_param(col)
			return @instance_options[:"#{col}"]
		end

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

		private

		def self.default_fields
			[:id, :descripcion, :nombre]
		end

		def self.permiso_accion_to_hash(permiso_accion)
			PermisoAccionSerializer.to_hash(permiso_accion)
		end

		def self.accion_to_hash(accion)
			return nil unless accion

			serialize_record(accion, [:id, :descripcion, :nombre, :mostrar_front])
		end

		def self.permiso_to_hash(permiso)
			return nil unless permiso

			PermisoSerializer.to_hash(permiso)
		end

		def serialize_permiso_accion(permiso_accion)
			{
				id: permiso_accion.id,
				accion: serialize_accion(permiso_accion.accion),
				permiso: serialize_permiso(object)
			}
		end

		def serialize_accion(accion)
			return nil unless accion

			{
				id: accion.id,
				descripcion: accion.descripcion,
				nombre: accion.nombre,
				mostrar_front: accion.mostrar_front
			}
		end

		def serialize_permiso(permiso)
			return nil unless permiso

			{
				id: permiso.id,
				descripcion: permiso.descripcion,
				nombre: permiso.nombre
			}
		end
end
