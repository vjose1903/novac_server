class TipoArticuloCuentaContableSerializer < ActiveModel::Serializer




  def descripcion_control
    object.cuenta_contable_control.descripcion
  end

  def codigo_control
    object.cuenta_contable_control.codigo
  end

  def label_control
    object.cuenta_contable_control.label
  end

  def is_control_control
    object.cuenta_contable_control.is_control
  end

  def descripcion_auxiliar
    object.cuenta_contable_auxiliar.descripcion
  end

  def codigo_auxiliar
    object.cuenta_contable_auxiliar.codigo
  end

  def label_auxiliar
    object.cuenta_contable_auxiliar.label
  end

  def is_control_auxiliar
    object.cuenta_contable_auxiliar.is_control
  end

end

class TipoArticuloCuentaContableSerializer
  extend FastSerializer
  extend ActiveModelSerializerFastAdapter

  def self.default_fields
    [:id, :key, :origen_tipo_id, :descripcion_control, :codigo_control, :is_control_control, :label_control, :descripcion_auxiliar, :codigo_auxiliar, :is_control_auxiliar, :label_auxiliar]
  end

  def self.fast_serialized_fields(record, params)
    fields = default_fields.select { |field| show_serialized_field?(params, field) }
    fields -= [:descripcion_control, :codigo_control, :is_control_control, :label_control] if record.cuenta_contable_control.nil?
    fields -= [:descripcion_auxiliar, :codigo_auxiliar, :is_control_auxiliar, :label_auxiliar] if record.cuenta_contable_auxiliar.nil?
    fields
  end
end
