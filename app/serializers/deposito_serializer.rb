class DepositoSerializer < ActiveModel::Serializer



  def cuenta_bancaria
    fast_serialize_parser(object.cuenta_bancaria, { id: true, descripcion: true, banco: true, numero_cuenta: true })
  end

  def divisa
    fast_serialize_parser(object.divisa, { id: true, nombre: true })
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

end

class DepositoSerializer
  extend FastSerializer
  extend ActiveModelSerializerFastAdapter

  def self.default_fields
    [:id, :tasa, :monto, :monto_local, :comentario, :numero_referencia, :fecha_equivalente, :fecha_anulacion, :estado, :cuenta_bancaria, :divisa, :user_creador, :last_user_update, :user_anulador]
  end
end
