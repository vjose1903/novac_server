class CuadreCajaDenominacion < ApplicationRecord
  self.table_name = 'cuadre_caja_denominaciones'

  DENOMINATION_TYPES = %w[bill coin foreign_currency].freeze

  belongs_to :cuadre_caja
  belongs_to :divisa, optional: true
  belongs_to :tasa_cambio, optional: true

  attr_accessor :closing_date

  validates :denomination_type, inclusion: { in: DENOMINATION_TYPES }
  validates :currency_code, presence: true
  validates :denomination_value, numericality: { greater_than: 0 }
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :exchange_rate, numericality: { greater_than: 0 }
  validates :local_currency_total, numericality: { greater_than_or_equal_to: 0 }
  validate :requires_registered_divisa
  validate :local_denominations_use_principal_divisa
  validate :foreign_currency_uses_non_principal_divisa

  before_validation :calculate_totals

  def local?
    divisa&.is_principal || currency_code.to_s.upcase == CuadreCaja::LOCAL_CURRENCY_CODE
  end

  private

  def calculate_totals
    apply_divisa_rate
    self.currency_code = currency_code.to_s.upcase.presence || CuadreCaja::LOCAL_CURRENCY_CODE
    self.exchange_rate = 1 if local?

    amount = BigDecimal(denomination_value.to_s) * BigDecimal(quantity.to_s)
    self.foreign_amount = local? ? 0 : amount.round(2)
    self.local_currency_total = (amount * BigDecimal(exchange_rate.to_s)).round(2)
  end

  def apply_divisa_rate
    return if divisa.nil?

    self.currency_code = divisa.code.to_s.upcase.presence || divisa.simbolo.to_s.upcase.presence || currency_code

    tasa = divisa.getMontoTasa(closing_date || cuadre_caja&.closing_date || Date.current)
    self.tasa_cambio = tasa if tasa
    self.exchange_rate = tasa&.valor || divisa.current_tasa || exchange_rate
  end

  def requires_registered_divisa
    errors.add(:divisa, 'debe estar registrada para usar denominaciones') if divisa.nil?
  end

  def local_denominations_use_principal_divisa
    return if divisa.nil? || denomination_type == 'foreign_currency'

    errors.add(:divisa, 'debe ser la divisa principal para billetes y monedas locales') unless divisa.is_principal
  end

  def foreign_currency_uses_non_principal_divisa
    return if divisa.nil? || denomination_type != 'foreign_currency'

    errors.add(:divisa, 'no puede ser la divisa principal para moneda extranjera') if divisa.is_principal
  end
end
