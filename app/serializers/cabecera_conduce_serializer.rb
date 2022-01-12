class CabeceraConduceSerializer < ActiveModel::Serializer
  attribute :id,                                 if: Proc.new { self.get_param('id') || self.get_param('all') }
  attribute :user_id,                            if: Proc.new { self.get_param('user_id') || self.get_param('all') }
  attribute :cliente_id,                         if: Proc.new { self.get_param('cliente_id') || self.get_param('all') }
  attribute :numero_conduce,                     if: Proc.new { self.get_param('numero_conduce') || self.get_param('all') }
  attribute :fecha_equivalente,                  if: Proc.new { self.get_param('fecha_equivalente') || self.get_param('all') }
  attribute :detalle_conduces,                   if: Proc.new { self.get_param('detalle_conduces') || self.get_param('all') }

  attribute :cliente,                            if: Proc.new { self.get_param('cliente') || self.get_param('all') }
  attribute :user,                               if: Proc.new { self.get_param('user') || self.get_param('all') }

  def detalle_conduces
    serialize_parser(object.detalle_conduces, {all: true})
  end

  def cliente
    serialize_parser(object.cliente, {documentos_de_identidad: true, nombre: true, apellido: true, direccion: true})
  end
  
  def user
    serialize_parser(object.user, {nombre: true, apellido: true})
  end
  
  def get_param(col)
		return @instance_options[:"#{col}"]
	end
end
