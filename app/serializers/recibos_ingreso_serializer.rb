class RecibosIngresoSerializer < ActiveModel::Serializer
  attribute :id,                                  if: Proc.new { self.personalizar_parametros('id') || self.personalizar_parametros('all') }
  attribute :user_id,                             if: Proc.new { self.personalizar_parametros('user_id') || self.personalizar_parametros('all') }
  attribute :cliente_id,                          if: Proc.new { self.personalizar_parametros('cliente_id') || self.personalizar_parametros('all') }
  attribute :total,                               if: Proc.new { self.personalizar_parametros('total') || self.personalizar_parametros('all') }
  attribute :forma_pago,                          if: Proc.new { self.personalizar_parametros('forma_pago') || self.personalizar_parametros('all') }
  attribute :tipo_factura_id,                     if: Proc.new { self.personalizar_parametros('tipo_factura_id') || self.personalizar_parametros('all') }
  attribute :devuelta,                            if: Proc.new { self.personalizar_parametros('devuelta') || self.personalizar_parametros('all') }
  attribute :fecha_equivalente,                   if: Proc.new { self.personalizar_parametros('fecha_equivalente') || self.personalizar_parametros('all') }
  attribute :estado,                              if: Proc.new { self.personalizar_parametros('estado') || self.personalizar_parametros('all') }
  attribute :vehiculo_id,                         if: Proc.new { self.personalizar_parametros('vehiculo_id') || self.personalizar_parametros('all') }
  attribute :incidencia,                          if: Proc.new { self.personalizar_parametros('incidencia') || self.personalizar_parametros('all') }
  attribute :numero_recibo,                       if: Proc.new { self.personalizar_parametros('numero_recibo') || self.personalizar_parametros('all') }
  attribute :detalle_recibos,                     if: Proc.new { self.personalizar_parametros('detalle_recibos') || self.personalizar_parametros('all') }
  
  attribute :chofer,                              if: Proc.new { self.personalizar_parametros('chofer') || self.personalizar_parametros('all') }
  attribute :cliente,                             if: Proc.new { self.personalizar_parametros('cliente') || self.personalizar_parametros('all') }
  attribute :user,                                if: Proc.new { self.personalizar_parametros('user') || self.personalizar_parametros('all') }
  attribute :detalle_recibos,                     if: Proc.new { self.personalizar_parametros('detalle_recibos') || self.personalizar_parametros('all') }

  def cliente
    serialize_parser(object.cliente, {documentos_de_identidad: true, nombre: true, apellido: true, direccion: true})
  end
  
  def user
    serialize_parser(object.user, {nombre: true, apellido: true})
  end

  def detalle_recibos
    serialize_parser(object.detalle_recibos, {all: true})
  end

  def chofer
    unless object.chofer.nil?
      chofer_ = User.find_by_id(object.chofer)
      puts "chofer_==> ".red + "#{chofer_}"
      serialize_parser(chofer_, {id:true, nombre: true, apellido: true, documentos_de_identidad: true,})
    else
      nil
    end
  end

  def personalizar_parametros(col)
		return @instance_options[:"#{col}"]
	end

end
