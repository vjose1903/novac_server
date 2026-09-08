class DetalleReciboSerializer < ActiveModel::Serializer
  extend FastSerializer


  def self.to_hash(object, params={})
    fields = default_fields.select { |field| show_serialized_field?(params, field) }
    serialize_record(object, fields, readers: readers)
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id, :recibos_ingreso_id, :cabecera_factura_id, :pago_total, :deposito, :mora, :balance_factura, :balance_anterior_factura, :descripcion, :pago_a_tiempo, :is_ultimo, :total_factura]
  end

  def self.readers
    {
      total_factura: ->(record) { record.cabecera_factura["total_factura"] }
    }
  end
end
