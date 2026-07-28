class CuadreCajaDenominacion < ApplicationRecord
  self.table_name = 'cuadre_caja_denominaciones'

  DENOMINATION_TYPES = %w[bill coin foreign_currency].freeze

  belongs_to :cuadre_caja

  validates :denomination_type, inclusion: { in: DENOMINATION_TYPES }
  validates :currency_code, presence: true
  validates :denomination_value, numericality: { greater_than: 0 }
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :exchange_rate, numericality: { greater_than: 0 }
  validates :local_currency_total, numericality: { greater_than_or_equal_to: 0 }

  before_validation :calculate_totals

  def local?
    currency_code.to_s.upcase == CuadreCaja::LOCAL_CURRENCY_CODE
  end

  private

  def calculate_totals
    self.currency_code = currency_code.to_s.upcase.presence || CuadreCaja::LOCAL_CURRENCY_CODE
    self.exchange_rate = 1 if local?

    amount = BigDecimal(denomination_value.to_s) * BigDecimal(quantity.to_s)
    self.foreign_amount = local? ? 0 : amount.round(2)
    self.local_currency_total = (amount * BigDecimal(exchange_rate.to_s)).round(2)
  end
end
