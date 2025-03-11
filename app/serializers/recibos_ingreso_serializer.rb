class RecibosIngresoSerializer < ActiveModel::Serializer
  attribute :id,                                  if: Proc.new { self.get_param('id') || self.get_param('all') }
  attribute :user_id,                             if: Proc.new { self.get_param('user_id') || self.get_param('all') }
  attribute :cliente_id,                          if: Proc.new { self.get_param('cliente_id') || self.get_param('all') }
  attribute :bruto,                               if: Proc.new { self.get_param('bruto') || self.get_param('all') }
  attribute :mora,                                if: Proc.new { self.get_param('mora') || self.get_param('all') }
  attribute :total,                               if: Proc.new { self.get_param('total') || self.get_param('all') }
  attribute :forma_pago,                          if: Proc.new { self.get_param('forma_pago') || self.get_param('all') }
  attribute :tipo_factura_id,                     if: Proc.new { self.get_param('tipo_factura_id') || self.get_param('all') }
  attribute :devuelta,                            if: Proc.new { self.get_param('devuelta') || self.get_param('all') }
  attribute :fecha_equivalente,                   if: Proc.new { self.get_param('fecha_equivalente') || self.get_param('all') }
  attribute :estado,                              if: Proc.new { self.get_param('estado') || self.get_param('all') }
  attribute :numero_recibo,                       if: Proc.new { self.get_param('numero_recibo') || self.get_param('all') }
  attribute :detalle_recibos,                     if: Proc.new { self.get_param('detalle_recibos') || self.get_param('all') }
  attribute :incidencias,                         if: Proc.new { self.get_param('incidencias') }

  attribute :cliente,                             if: Proc.new { self.get_param('cliente') || self.get_param('all') }
  attribute :user,                                if: Proc.new { self.get_param('user') || self.get_param('all') }
  attribute :detalle_recibos,                     if: Proc.new { self.get_param('detalle_recibos') || self.get_param('all') }


  def cliente
    serialize_parser(object.cliente, {documentos_de_identidad: true, nombre: true, apellido: true, direccion: true, balance: true, telefono: true})
  end

  def user
    serialize_parser(object.user, {nombre: true, apellido: true})
  end

  def detalle_recibos
    serialize_parser(object.detalle_recibos, {all: true})
  end

  def incidencias
    serialize_parser(object.incidencias, {all: true})
  end

  def get_param(col)
    return @instance_options[:"#{col}"]
  end

end
