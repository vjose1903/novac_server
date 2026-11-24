class CuentaContableSerializer < ActiveModel::Serializer



  def origen
    OrigenGrupo.get_label(object.origen)
  end

  def tipo
    TipoGrupo.get_label(object.tipo)
  end

  def cuenta_control
    fast_serialize_parser(object.cuenta_control, {id: true, descripcion: true, codigo: true, tipo: true, origen: true })
  end

  def label
    object.label
  end
end

class CuentaContableSerializer
  extend FastSerializer
  extend ActiveModelSerializerFastAdapter

  def self.default_fields
    [:id, :descripcion, :cuenta_control_id, :codigo, :grupo_cuenta_id, :nivel, :origen, :is_control, :estado, :tipo, :is_auto_created, :cuentas_contables, :cuenta_control, :label]
  end

  def self.fast_serialized_fields(record, params)
    fields = default_fields.select { |field| show_serialized_field?(params, field) }
    fields -= [:cuentas_contables, :cuenta_control, :label]
    fields << :cuentas_contables if params[:cuentas_contables]
    fields << :cuenta_control if params[:cuenta_control] && record.cuenta_control
    fields << :label if params[:label]
    fields
  end
end
