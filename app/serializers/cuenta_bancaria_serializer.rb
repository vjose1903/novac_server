class CuentaBancariaSerializer < ActiveModel::Serializer
  attributes :id, :numero_cuenta, :comentario, :descripcion, :fecha_apertura, :is_nacional, :estado
  has_one :banco
  has_one :tipo_cuenta_bancaria
  has_one :divisa
  has_one :cuenta_contable
end
