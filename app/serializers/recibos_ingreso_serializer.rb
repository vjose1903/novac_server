class RecibosIngresoSerializer < ActiveModel::Serializer
  extend FastSerializer

  attribute :id,                                  if: Proc.new { self.get_param('id') || self.get_param('all') }
  attribute :user_id,                             if: Proc.new { self.get_param('user_id') || self.get_param('all') }
  attribute :cliente_id,                          if: Proc.new { self.get_param('cliente_id') || self.get_param('all') }
  attribute :bruto,                               if: Proc.new { self.get_param('bruto') || self.get_param('all') }
  attribute :mora,                                if: Proc.new { self.get_param('mora') || self.get_param('all') }
  attribute :total,                               if: Proc.new { self.get_param('total') || self.get_param('all') }
  attribute :balance_cliente,                     if: Proc.new { self.get_param('balance_cliente') || self.get_param('all') }
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

  ALL_OR_FIELD_FIELDS = [:id, :user_id, :cliente_id, :bruto, :mora, :total, :balance_cliente, :forma_pago, :tipo_factura_id, :devuelta, :fecha_equivalente, :estado, :numero_recibo, :detalle_recibos, :cliente, :user].freeze

  def get_param(col)
    return @instance_options[:"#{col}"]
  end

  def cliente
    ClienteSerializer.to_hash(object.cliente, {documentos_de_identidad: true, nombre: true, apellido: true, direccion: true, balance: true, telefono: true, nombre_completo: true})
  end

  def user
    UserSerializer.to_hash(object.user, {nombre: true, apellido: true})
  end

  def detalle_recibos
    DetalleReciboSerializer.collection_to_hash(object.detalle_recibos, {all: true})
  end

  def incidencias
    IncidenciaSerializer.collection_to_hash(object.incidencias, {all: true})
  end

  def self.to_hash(object, params={})
    fields = default_fields.select { |field| show_field?(field, params) }
    serialize_record(object, fields, readers: readers(params))
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id, :user_id, :cliente_id, :bruto, :mora, :total, :balance_cliente, :forma_pago, :tipo_factura_id, :devuelta, :fecha_equivalente, :estado, :numero_recibo, :detalle_recibos, :incidencias, :cliente, :user]
  end

  def self.show_field?(field, params)
    ALL_OR_FIELD_FIELDS.include?(field) ? (params[:all] || params[field]) : params[field]
  end

  def self.readers(params)
    {
      cliente: ->(record) { ClienteSerializer.to_hash(record.cliente, {documentos_de_identidad: true, nombre: true, apellido: true, direccion: true, balance: true, telefono: true, nombre_completo: true}) },
      user: ->(record) { UserSerializer.to_hash(record.user, {nombre: true, apellido: true}) },
      detalle_recibos: ->(record) { DetalleReciboSerializer.collection_to_hash(record.detalle_recibos, {all: true}) },
      incidencias: ->(record) { IncidenciaSerializer.collection_to_hash(record.incidencias, {all: true}) }
    }
  end
end
