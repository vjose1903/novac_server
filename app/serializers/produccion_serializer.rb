class ProduccionSerializer < ActiveModel::Serializer
  extend FastSerializer



  def self.to_hash(object, params={})
    serialize_record(object, default_fields.select { |field| show_serialized_field?(params, field) }, readers: {
      detalles_produccion: ->(produccion) { DetalleProduccionSerializer.collection_to_hash(produccion.detalles_produccion, { all: true }) },
      user: ->(produccion) { user_to_hash(produccion) }
    })
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id, :user_id, :numero, :fecha_equivalente, :detalles_produccion, :user]
  end

  def self.user_to_hash(produccion)
    user = produccion.user
    user ? UserSerializer.to_hash(user, { nombre: true, apellido: true }) : nil
  end


  
end
