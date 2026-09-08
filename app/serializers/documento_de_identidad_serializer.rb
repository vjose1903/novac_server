class DocumentoDeIdentidadSerializer < ActiveModel::Serializer
  extend FastSerializer






  def self.to_hash(object, params={})
    data = serialize_record(object, default_fields.select { |field| show_serialized_field?(params, field) })
    if params[:persona]
      data[:persona] = persona_to_hash(object)
      data[:persona_is] = object.origen_type
    end
    data
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id, :descripcion, :documento, :principal]
  end

  def self.persona_to_hash(object)
    return nil unless object.origen

    serializer = "#{object.origen_type}Serializer".safe_constantize
    return nil unless serializer.respond_to?(:to_hash)

    serializer.to_hash(object.origen, { all: true, documentos_de_identidad: true })
  end
end
