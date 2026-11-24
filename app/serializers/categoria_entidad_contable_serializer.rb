class CategoriaEntidadContableSerializer < ActiveModel::Serializer


  def is_nacional
    object.configuracion_entidad_cuenta&.is_nacional
  end

  def cuenta_contable_control
    fast_serialize_parser(object.cuenta_contable_control, { id: true, descripcion: true, codigo: true, label: true })
  end

  def cuenta_contable_auxiliar
    fast_serialize_parser(object.cuenta_contable_auxiliar, { id: true, descripcion: true, codigo: true, label: true })
  end

end

class CategoriaEntidadContableSerializer
  extend FastSerializer
  extend ActiveModelSerializerFastAdapter

  def self.default_fields
    [:id, :descripcion, :entidad, :key, :is_nacional, :configuracion_entidad_cuenta_id, :cuenta_contable_control, :cuenta_contable_auxiliar]
  end
end
