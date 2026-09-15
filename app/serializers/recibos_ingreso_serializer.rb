class RecibosIngresoSerializer < ActiveModel::Serializer
  extend FastSerializer



  ALL_OR_FIELD_FIELDS = [:id, :user_id, :cliente_id, :bruto, :mora, :total, :balance_cliente, :forma_pago, :metodos_de_pago, :tipo_factura_id, :devuelta, :fecha_equivalente, :estado, :numero_recibo, :detalle_recibos, :cliente, :user].freeze






  def self.to_hash(object, params={})
    fields = default_fields.select { |field| show_field?(field, params) }
    serialize_record(object, fields, readers: readers(params))
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id, :user_id, :cliente_id, :bruto, :mora, :total, :balance_cliente, :forma_pago, :metodos_de_pago, :tipo_factura_id, :devuelta, :fecha_equivalente, :estado, :numero_recibo, :detalle_recibos, :incidencias, :cliente, :user]
  end

  def self.show_field?(field, params)
    ALL_OR_FIELD_FIELDS.include?(field) ? (params[:all] || params[field]) : params[field]
  end

  def self.readers(params)
    {
      cliente: ->(record) { ClienteSerializer.to_hash(record.cliente, {documentos_de_identidad: true, nombre: true, apellido: true, direccion: true, balance: true, telefono: true, nombre_completo: true}) },
      user: ->(record) { UserSerializer.to_hash(record.user, {nombre: true, apellido: true}) },
      detalle_recibos: ->(record) { DetalleReciboSerializer.collection_to_hash(record.detalle_recibos, {all: true}) },
      metodos_de_pago: ->(record) { record.metodos_de_pago.map { |pago| { id: pago.id, forma_pago: pago.forma_pago, monto: pago.monto } } },
      incidencias: ->(record) { IncidenciaSerializer.collection_to_hash(record.incidencias, {all: true}) }
    }
  end
end
