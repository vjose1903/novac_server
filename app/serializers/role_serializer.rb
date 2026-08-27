class RoleSerializer < ActiveModel::Serializer
	extend FastSerializer

	attribute :id,                         if: Proc.new { self.get_param('id') || self.get_param('all') }
	attribute :descripcion,                if: Proc.new { self.get_param('descripcion') || self.get_param('all') }
	attribute :nombre,                     if: Proc.new { self.get_param('nombre') || self.get_param('all') }
	attribute :ruta_defecto,               if: Proc.new { self.get_param('ruta_defecto') || self.get_param('all') }
	attribute :estado,                     if: Proc.new { self.get_param('estado') || self.get_param('all') }

  attribute :permisos_acciones,          if: Proc.new { self.get_param('permisos_acciones')}


	def permisos_acciones
		object.permisos_acciones.map { |permiso_accion| serialize_permiso_accion(permiso_accion) }
	end

	def get_param(col)
		return @instance_options[:"#{col}"]
	end

		def self.to_hash(object, include_permisos_acciones: false)
			data = serialize_record(object, default_fields)

			data[:permisos_acciones] = object.permisos_acciones.map { |permiso_accion| permiso_accion_to_hash(permiso_accion) } if include_permisos_acciones
			data
		end

	def self.collection_to_hash(collection, include_permisos_acciones: false)
		collection.map { |object| to_hash(object, include_permisos_acciones: include_permisos_acciones) }
	end

		private

		def self.default_fields
			[:id, :descripcion, :nombre, :ruta_defecto, :estado]
		end

		def self.permiso_accion_to_hash(permiso_accion)
			{
				id: permiso_accion.id,
				accion: accion_to_hash(permiso_accion.accion),
			permiso: permiso_to_hash(permiso_accion.permiso)
		}
	end

		def self.accion_to_hash(accion)
			return nil unless accion

			serialize_record(accion, [:id, :descripcion, :nombre, :mostrar_front])
		end

		def self.permiso_to_hash(permiso)
			return nil unless permiso

			serialize_record(permiso, [:id, :descripcion, :nombre])
		end

	def serialize_permiso_accion(permiso_accion)
		{
			id: permiso_accion.id,
			accion: serialize_accion(permiso_accion.accion),
			permiso: serialize_permiso(permiso_accion.permiso)
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
