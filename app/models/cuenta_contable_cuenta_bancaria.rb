class CuentaContableCuentaBancaria < ApplicationRecord
  belongs_to :cuenta_bancaria
  belongs_to :cuenta_contable
end
