class CuentaBancariaSerializer < ActiveModel::Serializer


  def cuenta_contable
    fast_serialize_parser(object.cuenta_contable, {id: true, descripcion: true, codigo: true})
  end

  def cuenta_contable_prima
    fast_serialize_parser(object.cuenta_contable_prima, {id: true, descripcion: true, codigo: true})
  end

  def divisa
    fast_serialize_parser(object.divisa, { id: true, nombre: true, imagen: true })

  end
  def banco
    fast_serialize_parser(object.banco, { id: true, nombre: true, comentario: true, estado: true })
  end

  def tipo_cuenta_bancaria
    object.tipo_cuenta_bancaria.descripcion
  end

  def info_completa
    object.info_completa
  end
end

class CuentaBancariaSerializer
  extend FastSerializer
  extend ActiveModelSerializerFastAdapter

  def self.default_fields
    [:id, :numero_cuenta, :comentario, :descripcion, :fecha_apertura, :estado, :balance_inicial_libro, :balance_inicial_banco, :fecha_primera_conciliacion, :banco_id, :divisa_id, :tipo_cuenta_bancaria_id, :has_chequera, :cuenta_contable, :cuenta_contable_prima, :divisa, :banco, :tipo_cuenta_bancaria, :info_completa]
  end

  def self.fast_serialized_fields(record, params)
    fields = default_fields.select { |field| show_serialized_field?(params, field) }
    fields.delete(:cuenta_contable_prima) if record.cuenta_contable_prima.nil?
    fields
  end
end
