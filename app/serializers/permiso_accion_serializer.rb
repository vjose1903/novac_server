class PermisoAccionSerializer < ActiveModel::Serializer
  attribute :id
	attribute :accion
	attribute :permiso

	def permiso
		serialize_parser(object.permiso, {all: true})
	end

	def accion
		serialize_parser(object.accion, {all: true})
	end

end
