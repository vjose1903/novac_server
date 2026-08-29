class DetalleReciboSerializer < ActiveModel::Serializer
  extend FastSerializer

  attribute :id,                                               if: Proc.new { self.get_param('id') || self.get_param('all') }
  attribute :recibos_ingreso_id,                               if: Proc.new { self.get_param('recibos_ingreso_id') || self.get_param('all') }
  attribute :cabecera_factura_id,                              if: Proc.new { self.get_param('cabecera_factura_id') || self.get_param('all') }
  attribute :pago_total,                                       if: Proc.new { self.get_param('pago_total') || self.get_param('all') }
  attribute :deposito,                                         if: Proc.new { self.get_param('deposito') || self.get_param('all') }
  attribute :mora,                                             if: Proc.new { self.get_param('mora') || self.get_param('all') }
  attribute :balance_factura,                                  if: Proc.new { self.get_param('balance_factura') || self.get_param('all') }
  attribute :balance_anterior_factura,                         if: Proc.new { self.get_param('balance_anterior_factura') || self.get_param('all') }
  attribute :descripcion,                                      if: Proc.new { self.get_param('descripcion') || self.get_param('all') }
  attribute :pago_a_tiempo,                                    if: Proc.new { self.get_param('pago_a_tiempo') || self.get_param('all') }
  attribute :is_ultimo,                                        if: Proc.new { self.get_param('is_ultimo') || self.get_param('all') }
  attribute :total_factura,                                    if: Proc.new { self.get_param('total_factura') || self.get_param('all') }

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
