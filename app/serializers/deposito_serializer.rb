class DepositoSerializer < ActiveModel::Serializer
  attributes :id, :tasa, :monto, :monto_local, :comentario, :numero_referencia, :fecha_equivalente, :fecha_anulacion, :estado
  has_one :cuenta_bancaria
  has_one :user
  has_one :user_anulador
end
