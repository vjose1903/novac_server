class CabeceraConduceSerializer < ActiveModel::Serializer
  attribute :id,                                 if: Proc.new { self.personalizar_parametros('id') || self.personalizar_parametros('all') }
  attribute :user_id,                            if: Proc.new { self.personalizar_parametros('user_id') || self.personalizar_parametros('all') }
  attribute :cliente_id,                         if: Proc.new { self.personalizar_parametros('cliente_id') || self.personalizar_parametros('all') }
  attribute :numero_conduce,                     if: Proc.new { self.personalizar_parametros('numero_conduce') || self.personalizar_parametros('all') }
  attribute :fecha_equivalente,                  if: Proc.new { self.personalizar_parametros('fecha_equivalente') || self.personalizar_parametros('all') }
  attribute :detalle_conduces,                   if: Proc.new { self.personalizar_parametros('detalle_conduces') || self.personalizar_parametros('all') }

  attribute :cliente,                            if: Proc.new { self.personalizar_parametros('cliente') || self.personalizar_parametros('all') }
  attribute :user,                               if: Proc.new { self.personalizar_parametros('user') || self.personalizar_parametros('all') }

  def detalle_conduces
    serialize_parser(object.detalle_conduces, {all: true})
  end

  def cliente
    serialize_parser(object.cliente, {documentos_de_identidad: true, nombre: true, apellido: true, direccion: true})
  end
  
  def user
    serialize_parser(object.user, {nombre: true, apellido: true})
  end
  
  def personalizar_parametros(col)
		return @instance_options[:"#{col}"]
	end
end
