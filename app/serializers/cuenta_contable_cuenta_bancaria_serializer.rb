class CuentaContableCuentaBancariaSerializer < ActiveModel::Serializer
  attributes :id, :is_prima
  has_one :cuenta_bancaria
  has_one :cuenta_contable
end
