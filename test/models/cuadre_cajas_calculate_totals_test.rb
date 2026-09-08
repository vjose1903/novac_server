require 'test_helper'

class CuadreCajasCalculateTotalsTest < ActiveSupport::TestCase
  setup do
    @principal_divisa = Divisa.create!(nombre: 'Peso test', simbolo: 'DOP', estado: true, is_principal: true, current_tasa: 1)
  end

  test 'calcula el cuadre detallado con los valores del Excel' do
    denominaciones = [
      bill(50, 34),
      bill(100, 130),
      bill(200, 5),
      bill(500, 34),
      bill(1000, 44),
      bill(2000, 65),
      coin(5, 51),
      coin(10, 7),
      coin(25, 22)
    ]

    movimientos = [
      movement('other_payment_methods', 'card', 'Tarjetas', 342_547.21),
      movement('other_payment_methods', 'petty_cash_check', 'CK Caja Chica', 28_222.41),
      movement('other_payment_methods', 'check', 'CK Arreglo Camion', 24_200),
      movement('other_payment_methods', 'deposit', 'Deposito', 376_000),
      movement('other_payment_methods', 'bank_transfer', 'Transf Suprosel', 100_000),
      movement('additional_transfers', 'bank_transfer', 'Transf Agro Camila', 25_000),
      movement('additional_transfers', 'bank_transfer', 'Transf Yovanny Rojas', 142_920),
      movement('additional_transfers', 'bank_transfer', 'Transf Mari', 4_000),
      movement('additional_transfers', 'check', 'CK Eddy Santos', 12_000)
    ]

    totals = CuadreCajas::CalculateTotals.call(
      denominaciones: denominaciones,
      movimientos: movimientos,
      system_income: {
        final_consumer_invoices_total: 588_122.54,
        income_receipts_total: 662_340,
        system_income_total: 1_250_462.54
      },
      tolerance: 0
    )

    assert_equal BigDecimal('206700.00'), totals[:local_bills_total]
    assert_equal BigDecimal('875.00'), totals[:local_coins_total]
    assert_equal BigDecimal('207575.00'), totals[:physical_cash_total]
    assert_equal BigDecimal('870969.62'), totals[:other_payment_methods_total]
    assert_equal BigDecimal('183920.00'), totals[:additional_transfers_total]
    assert_equal BigDecimal('1262464.62'), totals[:operational_total]
    assert_equal BigDecimal('1250462.54'), totals[:system_income_total]
    assert_equal BigDecimal('12002.08'), totals[:difference_amount]
    assert_equal false, totals[:considered_balanced]
  end

  test 'convierte moneda extranjera y aplica tolerancia' do
    divisa = Divisa.create!(nombre: 'Dolar test', simbolo: 'USD', estado: true, is_principal: false, current_tasa: 60)
    TasaCambio.create!(divisa: divisa, fecha_equivalente: Date.new(2026, 7, 24), valor: 58.90)

    denominacion = CuadreCajaDenominacion.new(
      denomination_type: 'foreign_currency',
      divisa_id: divisa.id,
      denomination_value: 100,
      quantity: 2
    )
    denominacion.closing_date = Date.new(2026, 7, 24)
    denominacion.valid?

    totals = CuadreCajas::CalculateTotals.call(
      denominaciones: [denominacion],
      movimientos: [],
      system_income: { system_income_total: 11_780 },
      tolerance: 0
    )

    assert_equal BigDecimal('11780.00'), totals[:foreign_currency_total]
    assert_equal BigDecimal('58.900000'), denominacion.exchange_rate
    assert_equal divisa.id, denominacion.divisa_id
    assert_equal BigDecimal('0.00'), totals[:difference_amount]
    assert_equal true, totals[:considered_balanced]
  end

  test 'rechaza denominacion sin divisa registrada' do
    denominacion = CuadreCajaDenominacion.new(
      denomination_type: 'bill',
      currency_code: 'DOP',
      denomination_value: 100,
      quantity: 1
    )

    assert_not denominacion.valid?
    assert_includes denominacion.errors[:divisa], 'debe estar registrada para usar denominaciones'
  end

  test 'rechaza billetes o monedas con divisa no principal' do
    divisa = Divisa.create!(nombre: 'Euro test', simbolo: 'EUR', estado: true, is_principal: false, current_tasa: 63)
    denominacion = CuadreCajaDenominacion.new(
      denomination_type: 'bill',
      divisa_id: divisa.id,
      denomination_value: 100,
      quantity: 1
    )

    assert_not denominacion.valid?
    assert_includes denominacion.errors[:divisa], 'debe ser la divisa principal para billetes y monedas locales'
  end

  test 'rechaza moneda extranjera con divisa principal' do
    denominacion = CuadreCajaDenominacion.new(
      denomination_type: 'foreign_currency',
      divisa_id: @principal_divisa.id,
      denomination_value: 100,
      quantity: 1
    )

    assert_not denominacion.valid?
    assert_includes denominacion.errors[:divisa], 'no puede ser la divisa principal para moneda extranjera'
  end

  private

  def bill(value, quantity)
    denomination('bill', value, quantity)
  end

  def coin(value, quantity)
    denomination('coin', value, quantity)
  end

  def denomination(type, value, quantity)
    item = CuadreCajaDenominacion.new(
      denomination_type: type,
      divisa_id: @principal_divisa.id,
      denomination_value: value,
      quantity: quantity
    )
    item.valid?
    item
  end

  def movement(group, method, description, amount)
    CuadreCajaMovimiento.new(
      movement_group: group,
      payment_method: method,
      description: description,
      amount: amount
    )
  end
end
