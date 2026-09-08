class SuplidorSerializer < ActiveModel::Serializer
  extend FastSerializer





  def self.to_hash(object, params={})
    data = serialize_record(object, default_fields.select { |field| show_serialized_field?(params, field) })
    data[:documentos_de_identidad] = documentos_de_identidad_to_hash(object, params[:documentos_de_identidad], params[:all]) if show_serialized_field?(params, :documentos_de_identidad)
    data[:nombre_completo] = object.nombre_completo if show_serialized_field?(params, :nombre_completo)
    data
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id, :nombre, :telefono, :direccion, :email, :estado]
  end

  def self.documentos_de_identidad_to_hash(object, param=true, include_all=false)
    fields = selected_serialized_fields(param, DocumentoDeIdentidadSerializer.default_fields, include_all: include_all)
    fields_params = fields.each_with_object({ all: false }) { |field, hash| hash[field] = true }
    DocumentoDeIdentidadSerializer.collection_to_hash(object.documentos_de_identidad, fields_params)
  end
end
