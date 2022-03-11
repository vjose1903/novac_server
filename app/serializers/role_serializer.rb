class RoleSerializer < ActiveModel::Serializer
  attributes :id, :descripcion, :nombre, :ruta_defecto, :activo
  attribute :permisos_acciones,                           if: Proc.new { self.get_param('permisos_acciones')}

	def permisos_acciones
		serialize_parser(object.permisos_acciones, {all: true})
	end

	def get_param(col)
		return @instance_options[:"#{col}"]
	end
end
