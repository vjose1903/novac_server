class TipoArticuloSerializer < ActiveModel::Serializer
  extend FastSerializer

  def self.to_hash(object, params={})
    fields = default_fields.select { |field| show_serialized_field?(params, field) }
    readers = {
      cuentas_contables: ->(tipo_articulo) {
        TipoArticuloCuentaContableSerializer.collection_to_hash(tipo_articulo.tipo_articulo_cuentas_contables, { all: true })
      }
    }

    serialize_record(object, fields, readers: readers)
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id, :descripcion, :created_at, :updated_at, :tipo, :codigo, :cuentas_contables]
  end
end
