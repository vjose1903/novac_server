class PermisoAccionSerializer < ActiveModel::Serializer
  attribute :id
	attribute :accion
	attribute :permiso

	def permiso
		serialize_permiso(object.permiso)
	end

	def accion
		serialize_accion(object.accion)
	end

	private

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
