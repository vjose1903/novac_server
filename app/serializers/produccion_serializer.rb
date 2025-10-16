class ProduccionSerializer < ActiveModel::Serializer
  attribute :id,                                 if: Proc.new { self.get_param('id') || self.get_param('all') }
  attribute :user_id,                            if: Proc.new { self.get_param('user_id') || self.get_param('all') }
  attribute :numero,                             if: Proc.new { self.get_param('numero') || self.get_param('all') }
  attribute :fecha_equivalente,                  if: Proc.new { self.get_param('fecha_equivalente') || self.get_param('all') }
  attribute :detalles_produccion,                   if: Proc.new { self.get_param('detalles_produccion') || self.get_param('all') }

  attribute :user,                               if: Proc.new { self.get_param('user') || self.get_param('all') }

  def detalles_produccion
    serialize_parser(object.detalles_produccion, {all: true})
  end
  
  def user
    serialize_parser(object.user, {nombre: true, apellido: true})
  end
  
  def get_param(col)
		return @instance_options[:"#{col}"]
	end
end
