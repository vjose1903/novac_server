class FacturaAplicadaSerializer < ActiveModel::Serializer
  extend FastSerializer



  ALL_OR_FIELD_FIELDS = [:id, :total, :cabecera_factura, :detalles_facturas_notas, :fecha_equivalente].freeze


  def self.to_hash(object, params={})
    fields = default_fields.select { |field| show_field?(field, params) }
    serialize_record(object, fields, readers: readers(params))
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id, :total, :cabecera_factura, :detalles_facturas_notas, :fecha_equivalente, :numero_comprobante, :user_id, :estado, :tipo, :tipo_label]
  end

  def self.show_field?(field, params)
    ALL_OR_FIELD_FIELDS.include?(field) ? (params[:all] || params[field]) : params[field]
  end

  def self.readers(params)
    {
      id: ->(record) { params[:usar_id_nota] ? record.nota_id : record.id },
      cabecera_factura: ->(record) { CabeceraFacturaSerializer.to_hash(record.cabecera_factura, {id: true, numero_comprobante: true, fecha_equivalente: true}) },
      detalles_facturas_notas: ->(record) { DetalleFacturaNotaSerializer.collection_to_hash(record.detalles_facturas_notas, {all: true}) },
      fecha_equivalente: ->(record) { record.nota.fecha_equivalente },
      numero_comprobante: ->(record) { record.nota.numero_comprobante },
      user_id: ->(record) { record.nota.user_id },
      estado: ->(record) { record.nota.estado },
      tipo: ->(record) { record.tipo_nota },
      tipo_label: ->(record) { record.tipo_nota == TiposNotas.credito ? 'Crédito' : 'Débito' }
    }
  end
end
