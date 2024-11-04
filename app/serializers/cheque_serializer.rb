class ChequeSerializer < ActiveModel::Serializer
  attributes :id, :tasa, :monto, :monto_local, :balance, :comentario, :fecha_equivalente, :fecha_update, :fecha_anulacion, :secuencia, :estado
  has_one :cuenta_bancaria
  has_one :user_creador
  has_one :last_user_update
  has_one :user_anulador
end
