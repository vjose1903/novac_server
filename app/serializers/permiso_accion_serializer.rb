class PermisoAccionSerializer < ActiveModel::Serializer
  extend FastSerializer

  attribute :id
  attribute :accion
  attribute :permiso

  ALL_OR_FIELD_FIELDS = [:id, :accion, :permiso].freeze

  def permiso
    serialize_permiso(object.permiso)
  end

  def accion
    serialize_accion(object.accion)
  end

  def self.to_hash(object, params={})
    serialize_record(object, default_fields, readers: readers)
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    ALL_OR_FIELD_FIELDS
  end

  def self.show_field?(field, params)
    params[:all] || has_to_show(params[field])
  end

  def self.readers
    {
      accion: ->(record) { serialize_accion(record.accion) },
      permiso: ->(record) { serialize_permiso(record.permiso) }
    }
  end

  def self.serialize_accion(accion)
    return nil unless accion

    {
      id: accion.id,
      descripcion: accion.descripcion,
      nombre: accion.nombre,
      mostrar_front: accion.mostrar_front
    }
  end

  def self.serialize_permiso(permiso)
    return nil unless permiso

    {
      id: permiso.id,
      descripcion: permiso.descripcion,
      nombre: permiso.nombre
    }
  end
  private_class_method :serialize_accion, :serialize_permiso

  private

  def serialize_accion(accion)
    return nil unless accion

    {
      id: accion.id,
      descripcion: accion.descripcion,
      nombre: accion.nombre,
      mostrar_front: accion.mostrar_front
    }
  end

  def serialize_permiso(permiso)
    return nil unless permiso

    {
      id: permiso.id,
      descripcion: permiso.descripcion,
      nombre: permiso.nombre
    }
  end
end
