class CuadreCajaMovimiento < ApplicationRecord
  self.table_name = 'cuadre_caja_movimientos'

  MOVEMENT_GROUPS = %w[other_payment_methods additional_transfers].freeze
  PAYMENT_METHODS = %w[card check deposit bank_transfer petty_cash_check other].freeze
  DEFAULT_DESCRIPTIONS = {
    'card' => 'Tarjeta',
    'check' => 'Cheque',
    'deposit' => 'Depósito',
    'bank_transfer' => 'Transferencia bancaria',
    'petty_cash_check' => 'Cheque de caja chica',
    'other' => 'Otro movimiento'
  }.freeze

  belongs_to :cuadre_caja

  validates :movement_group, inclusion: { in: MOVEMENT_GROUPS }
  validates :payment_method, inclusion: { in: PAYMENT_METHODS }
  validates :amount, numericality: { greater_than_or_equal_to: 0 }

  before_validation :normalize_fields

  private

  def normalize_fields
    self.movement_group = movement_group.to_s
    self.payment_method = payment_method.to_s
    self.description = description.to_s.strip
    self.description = DEFAULT_DESCRIPTIONS.fetch(payment_method, 'Movimiento') if description.blank?
  end
end
