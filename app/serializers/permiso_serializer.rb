class PermisoSerializer < ActiveModel::Serializer
  attributes :id, :descripcion, :nombre
  attribute :acciones,                        if: Proc.new { self.get_param('acciones')}
  attribute :permisos_acciones,               if: Proc.new { self.get_param('permisos_acciones')}

	def acciones
		serialize_parser(object.acciones, {all: true})
	end

	def permisos_acciones
		relation = object.permisos_acciones.joins(:accion).includes(:accion, :permiso).where(accion: { mostrar_front: true })
		serialize_parser(relation, { all: true })
	end

	def get_param(col)
		return @instance_options[:"#{col}"]
	end
end