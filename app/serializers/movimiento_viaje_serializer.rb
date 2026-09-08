class MovimientoViajeSerializer < ActiveModel::Serializer
  extend FastSerializer







  def self.to_hash(object, params={})
    serialize_record(object, default_fields, readers: readers(params))
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id, :chofer, :vehiculo, :vehiculo_id, :user_id]
  end

  def self.readers(params)
    {
      chofer: ->(record) { UserSerializer.to_hash(record.user, { id: true, nombre: true, apellido: true, documentos_de_identidad: true }) },
      vehiculo: ->(record) { VehiculoSerializer.to_hash(record.vehiculo, { id: true, propietario: true, user_id: true, info_vehiculo: true, marca_modelo_anio: params[:marca_modelo_anio] || false }) }
    }
  end
end
