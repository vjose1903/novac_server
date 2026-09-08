class CuadreCajaEventoSerializer < ActiveModel::Serializer
  extend FastSerializer


  ALL_OR_FIELD_FIELDS = [:id, :event_type, :from_status, :to_status, :reason, :metadata, :created_at, :user].freeze



  def self.to_hash(object, params={})
    fields = default_fields.select { |field| show_field?(field, params) }
    serialize_record(object, fields, readers: readers)
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id, :event_type, :from_status, :to_status, :reason, :metadata, :created_at, :user]
  end

  def self.show_field?(field, params)
    ALL_OR_FIELD_FIELDS.include?(field) ? (params[:all] || params[field]) : params[field]
  end

  def self.readers
    {
      created_at: ->(record) { record.created_at&.as_json },
      user: ->(record) { record.user ? UserSerializer.to_hash(record.user, { id: true, nombre: true, apellido: true, nombre_completo: true }) : nil }
    }
  end
end
