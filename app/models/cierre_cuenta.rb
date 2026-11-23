class CierreCuenta < ApplicationRecord
  belongs_to :periodo_fiscal
  belongs_to :cuenta_contable
end
