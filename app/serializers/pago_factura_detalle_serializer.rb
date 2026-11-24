class PagoFacturaDetalleSerializer < ActiveModel::Serializer

  def total_factura
    factura =  object.cabecera_factura
    factura["total_factura"]
  end
end

class PagoFacturaDetalleSerializer
  extend FastSerializer
  extend ActiveModelSerializerFastAdapter

  def self.default_fields
    [:id, :pago_factura_id, :cabecera_factura_id, :deposito, :balance_factura, :balance_anterior_factura, :descripcion, :pago_a_tiempo, :is_ultimo, :total_factura]
  end
end
