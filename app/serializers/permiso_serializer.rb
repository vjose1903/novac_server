class PermisoSerializer < ActiveModel::Serializer
  attributes :id, :descripcion, :nombre
  attribute :acciones,                        if: Proc.new { self.get_param('acciones')}

	def acciones
		serialize_parser(object.acciones, {all: true})
	end

	def get_param(col)
		return @instance_options[:"#{col}"]
	end
end
