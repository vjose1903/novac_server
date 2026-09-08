class CabeceraConduceSerializer < ActiveModel::Serializer
  extend FastSerializer



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

    ClienteSerializer.to_hash(cliente, { nombre: true, apellido: true, telefono: true, direccion: true, nombre_completo: true, documentos_de_identidad: true })
  end
end
