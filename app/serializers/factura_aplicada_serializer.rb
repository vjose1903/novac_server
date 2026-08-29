class FacturaAplicadaSerializer < ActiveModel::Serializer
  extend FastSerializer

  attribute :id,                            if: Proc.new { self.get_param('all') || self.get_param('id')  }
  attribute :total,                         if: Proc.new { self.get_param('all') || self.get_param('total')  }
  attribute :cabecera_factura,              if: Proc.new { self.get_param('all') || self.get_param('cabecera_factura')  }
  attribute :detalles_facturas_notas,       if: Proc.new { self.get_param('all') || self.get_param('detalles_facturas_notas')  }
  attribute :fecha_equivalente,             if: Proc.new { self.get_param('all') || self.get_param('fecha_equivalente') }

  attribute :numero_comprobante,            if: Proc.new { self.get_param('numero_comprobante') }
  attribute :user_id,                       if: Proc.new { self.get_param('user_id') }
  attribute :estado,                        if: Proc.new { self.get_param('estado') }
  attribute :tipo,                          if: Proc.new { self.get_param('tipo') }
  attribute :tipo_label,                    if: Proc.new { self.get_param('tipo_label') }

  ALL_OR_FIELD_FIELDS = [:id, :total, :cabecera_factura, :detalles_facturas_notas, :fecha_equivalente].freeze

  def get_param(col)
    return @instance_options[:"#{col}"]
  end

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
      cabecera_factura: ->(record) { ActiveModelSerializers::SerializableResource.new(record.cabecera_factura, {id: true, numero_comprobante: true, fecha_equivalente: true}).as_json },
      detalles_facturas_notas: ->(record) { ActiveModelSerializers::SerializableResource.new(record.detalles_facturas_notas, {all: true}).as_json },
      fecha_equivalente: ->(record) { record.nota.fecha_equivalente },
      numero_comprobante: ->(record) { record.nota.numero_comprobante },
      user_id: ->(record) { record.nota.user_id },
      estado: ->(record) { record.nota.estado },
      tipo: ->(record) { record.tipo_nota },
      tipo_label: ->(record) { record.tipo_nota == TiposNotas.credito ? 'Crédito' : 'Débito' }
    }
  end
end
