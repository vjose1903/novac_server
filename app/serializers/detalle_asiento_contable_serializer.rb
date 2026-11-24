class DetalleAsientoContableSerializer < ActiveModel::Serializer

  def cuenta_contable_auxiliar
    fast_serialize_parser(object.cuenta_contable_auxiliar, { id: true, descripcion: true, codigo: true })
  end

  def cuenta_contable_control
    fast_serialize_parser(object.cuenta_contable_control, { id: true, descripcion: true, codigo: true })
  end
end

class DetalleAsientoContableSerializer
  extend FastSerializer
  extend ActiveModelSerializerFastAdapter

  def self.default_fields
    [:id, :valor_credito, :valor_debito, :cuenta_contable_auxiliar, :cuenta_contable_auxiliar_id, :cuenta_contable_control, :cuenta_contable_control_id]
  end
end
