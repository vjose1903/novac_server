class EntidadCuentaContableSerializer < ActiveModel::Serializer




  def cuenta_contable
    fast_serialize_parser(object.cuenta_contable, { id: true, descripcion: true, codigo: true, label: true })
  end

  def origen_categoria
    return nil if object.origen_categoria.nil?

    data = fast_serialize_parser(object.origen_categoria, { id: true, descripcion: true }).as_json
    data[:table_name] = object.origen_categoria.class.table_name
    data
  end

  def origen_entidad
    fast_serialize_parser(object.origen_entidad, { all: true })
  end
end

class EntidadCuentaContableSerializer
  extend FastSerializer
  extend ActiveModelSerializerFastAdapter

  def self.default_fields
    [:id, :configuracion_entidad_cuenta_id, :key, :tipo_agrupacion_contable, :is_comun, :cuenta_contable, :origen_categoria, :origen_entidad]
  end

  def self.fast_serialized_fields(record, params)
    fields = default_fields.select { |field| show_serialized_field?(params, field) }
    fields.delete(:origen_entidad) unless params[:origen_entidad]
    fields
  end
end
