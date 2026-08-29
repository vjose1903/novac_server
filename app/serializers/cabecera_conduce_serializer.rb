class CabeceraConduceSerializer < ActiveModel::Serializer
  extend FastSerializer

  attribute :id,                                 if: Proc.new { self.get_param('id') || self.get_param('all') }
  attribute :user_id,                            if: Proc.new { self.get_param('user_id') || self.get_param('all') }
  attribute :cliente_id,                         if: Proc.new { self.get_param('cliente_id') || self.get_param('all') }
  attribute :numero_conduce,                     if: Proc.new { self.get_param('numero_conduce') || self.get_param('all') }
  attribute :fecha_equivalente,                  if: Proc.new { self.get_param('fecha_equivalente') || self.get_param('all') }
  attribute :detalle_conduces,                   if: Proc.new { self.get_param('detalle_conduces') || self.get_param('all') }

  attribute :cliente,                            if: Proc.new { self.get_param('cliente') || self.get_param('all') }
  attribute :user,                               if: Proc.new { self.get_param('user') || self.get_param('all') }

  def self.to_hash(object, params={})
    fields = default_fields.select { |field| show_serialized_field?(params, field) }
    serialize_record(object, fields, readers: readers)
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id, :user_id, :cliente_id, :numero_conduce, :fecha_equivalente, :detalle_conduces, :cliente, :user]
  end

  def self.readers
    {
      detalle_conduces: ->(record) { DetalleConduceSerializer.collection_to_hash(record.detalle_conduces, {all: true}) },
      cliente: ->(record) { cliente_to_hash(record.cliente) },
      user: ->(record) { UserSerializer.to_hash(record.user, {nombre: true, apellido: true, nombre_completo: true}) }
    }
  end

  def self.cliente_to_hash(cliente)
    return nil unless cliente

    data = serialize_record(cliente, [:nombre, :apellido, :telefono, :direccion])
    data[:nombre_completo] = cliente.nombre_completo
    data[:documentos_de_identidad] = cliente.documentos_de_identidad.map do |documento|
      serialize_selected_record(documento, [:id, :descripcion, :documento, :principal])
    end
    data
  end
end
