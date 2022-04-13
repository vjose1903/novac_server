class RoleSerializer < ActiveModel::Serializer

	attribute :id,                         if: Proc.new { self.get_param('id') || self.get_param('all') }
	attribute :descripcion,                if: Proc.new { self.get_param('descripcion') || self.get_param('all') }
	attribute :nombre,                     if: Proc.new { self.get_param('nombre') || self.get_param('all') }
	attribute :ruta_defecto,               if: Proc.new { self.get_param('ruta_defecto') || self.get_param('all') }
	attribute :estado,                     if: Proc.new { self.get_param('estado') || self.get_param('all') }

  attribute :permisos_acciones,          if: Proc.new { self.get_param('permisos_acciones')}


	def permisos_acciones
		serialize_parser(object.permisos_acciones, {all: true})
	end

	def get_param(col)
		return @instance_options[:"#{col}"]
	end
end
