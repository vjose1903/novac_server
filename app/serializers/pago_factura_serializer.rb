class PagoFacturaSerializer < ActiveModel::Serializer



  def suplidor
    fast_serialize_parser(object.suplidor, {documentos_de_identidad: true, nombre: true, apellido: true, direccion: true, balance: true, telefono: true, nombre_completo: true})
  end

  def user
    fast_serialize_parser(object.user, {nombre: true, apellido: true})
  end

  def pago_factura_detalles
    fast_serialize_parser(object.pago_factura_detalles, {all: true})
  end
end

class PagoFacturaSerializer
  extend FastSerializer
  extend ActiveModelSerializerFastAdapter

  def self.default_fields
    [:id, :user_id, :suplidor_id, :total, :forma_pago, :tipo_factura_id, :fecha_equivalente, :estado, :numero, :suplidor, :user, :pago_factura_detalles]
  end
end
