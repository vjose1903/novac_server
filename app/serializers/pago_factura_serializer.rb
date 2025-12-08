class PagoFacturaSerializer < ActiveModel::Serializer
	attribute :id,                                  if: Proc.new { self.get_param('id')                || self.get_param('all') }
  attribute :user_id,                             if: Proc.new { self.get_param('user_id')           || self.get_param('all') }
  attribute :suplidor_id,                         if: Proc.new { self.get_param('suplidor_id')       || self.get_param('all') }
  attribute :total,                               if: Proc.new { self.get_param('total')             || self.get_param('all') }
  attribute :forma_pago,                          if: Proc.new { self.get_param('forma_pago')        || self.get_param('all') }
  attribute :tipo_factura_id,                     if: Proc.new { self.get_param('tipo_factura_id')   || self.get_param('all') }
  attribute :fecha_equivalente,                   if: Proc.new { self.get_param('fecha_equivalente') || self.get_param('all') }
  attribute :estado,                              if: Proc.new { self.get_param('estado')            || self.get_param('all') }
  attribute :numero,                              if: Proc.new { self.get_param('numero')            || self.get_param('all') }

  attribute :suplidor,                            if: Proc.new { self.get_param('suplidor')          || self.get_param('all') }
  attribute :user,                                if: Proc.new { self.get_param('user')              || self.get_param('all') }
  attribute :pago_factura_detalles,                     if: Proc.new { self.get_param('pago_factura_detalles')   || self.get_param('all') }


  def suplidor
    serialize_parser(object.suplidor, {documentos_de_identidad: true, nombre: true, apellido: true, direccion: true, balance: true, telefono: true, nombre_completo: true})
  end

  def user
    serialize_parser(object.user, {nombre: true, apellido: true})
  end

  def pago_factura_detalles
    serialize_parser(object.pago_factura_detalles, {all: true})
  end

  def get_param(col)
    return @instance_options[:"#{col}"]
  end
end
