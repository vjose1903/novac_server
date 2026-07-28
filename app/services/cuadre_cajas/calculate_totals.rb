module CuadreCajas
  class CalculateTotals
    def self.call(denominaciones:, movimientos:, system_income:, tolerance:)
      new(denominaciones, movimientos, system_income, tolerance).call
    end

    def initialize(denominaciones, movimientos, system_income, tolerance)
      @denominaciones = denominaciones
      @movimientos = movimientos
      @system_income = system_income
      @tolerance = decimal(tolerance)
    end

    def call
      local_bills_total = sum_denominations('bill', CuadreCaja::LOCAL_CURRENCY_CODE)
      local_coins_total = sum_denominations('coin', CuadreCaja::LOCAL_CURRENCY_CODE)
      foreign_currency_total = sum_foreign_denominations
      physical_cash_total = local_bills_total + local_coins_total + foreign_currency_total
      other_payment_methods_total = sum_movements('other_payment_methods')
      additional_transfers_total = sum_movements('additional_transfers')
      operational_total = physical_cash_total + other_payment_methods_total + additional_transfers_total
      system_income_total = decimal(@system_income[:system_income_total])
      difference_amount = operational_total - system_income_total

      {
        local_bills_total: money(local_bills_total),
        local_coins_total: money(local_coins_total),
        foreign_currency_total: money(foreign_currency_total),
        physical_cash_total: money(physical_cash_total),
        other_payment_methods_total: money(other_payment_methods_total),
        additional_transfers_total: money(additional_transfers_total),
        operational_total: money(operational_total),
        final_consumer_invoices_total: money(@system_income[:final_consumer_invoices_total]),
        income_receipts_total: money(@system_income[:income_receipts_total]),
        system_income_total: money(system_income_total),
        difference_amount: money(difference_amount),
        considered_balanced: difference_amount.abs <= @tolerance,
        reconciliation_tolerance: money(@tolerance),
        system_income_details: @system_income[:details] || {}
      }
    end

    private

    def sum_denominations(type, currency_code)
      @denominaciones.select { |item| item.denomination_type == type && item.currency_code == currency_code }
        .sum { |item| decimal(item.local_currency_total) }
    end

    def sum_foreign_denominations
      @denominaciones.reject { |item| item.currency_code == CuadreCaja::LOCAL_CURRENCY_CODE }
        .sum { |item| decimal(item.local_currency_total) }
    end

    def sum_movements(group)
      @movimientos.select { |item| item.movement_group == group }
        .sum { |item| decimal(item.amount) }
    end

    def money(value)
      decimal(value).round(2)
    end

    def decimal(value)
      BigDecimal(value.to_s.presence || '0')
    end
  end
end
