class ChequeSerializer < ActiveModel::Serializer


  def divisa
    fast_serialize_parser(object.divisa, { id: true, nombre: true })
  end

  def cuenta_bancaria
    fast_serialize_parser(object.cuenta_bancaria, { id: true, descripcion: true, numero_cuenta: true, info_completa: true })
  end

  def user_creador
    fast_serialize_parser(object.user_creador, { id: true, nombre_completo: true })
  end

  def last_user_update
    fast_serialize_parser(object.last_user_update, { id: true, nombre_completo: true })
  end

  def user_anulador
    fast_serialize_parser(object.user_anulador, { id: true, nombre_completo: true })
  end

  def banco_obj
    banco = object.cuenta_bancaria&.banco
    { nombre: banco&.nombre || '', id: banco&.id }
  end
end

class ChequeSerializer
  extend FastSerializer
  extend ActiveModelSerializerFastAdapter

  def self.default_fields
    [:id, :tasa, :monto, :monto_local, :balance, :comentario, :fecha_equivalente, :fecha_update, :fecha_anulacion, :secuencia, :estado, :divisa, :cuenta_bancaria, :user_creador, :last_user_update, :user_anulador, :banco_obj]
  end
end
