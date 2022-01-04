class ProduccionSerializer < ActiveModel::Serializer
  attribute :id,                                 if: Proc.new { self.personalizar_parametros('id') || self.personalizar_parametros('all') }
  attribute :user_id,                            if: Proc.new { self.personalizar_parametros('user_id') || self.personalizar_parametros('all') }
  attribute :numero,                             if: Proc.new { self.personalizar_parametros('numero') || self.personalizar_parametros('all') }
  attribute :fecha_equivalente,                  if: Proc.new { self.personalizar_parametros('fecha_equivalente') || self.personalizar_parametros('all') }
  attribute :detalles_produccion,                   if: Proc.new { self.personalizar_parametros('detalles_produccion') || self.personalizar_parametros('all') }

  attribute :user,                               if: Proc.new { self.personalizar_parametros('user') || self.personalizar_parametros('all') }

  def detalles_produccion
    serialize_parser(object.detalles_produccion, {all: true})
  end
  
  def user
    serialize_parser(object.user, {nombre: true, apellido: true})
  end
  
  def personalizar_parametros(col)
		return @instance_options[:"#{col}"]
	end
end
