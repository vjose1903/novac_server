require 'test_helper'

class CuadreCajaTest < ActiveSupport::TestCase
  test 'restaura movimientos sugeridos al valor esperado y conserva movimientos manuales' do
    cuadre = CuadreCaja.create!(closing_date: Date.new(2026, 10, 17), closing_version: 'detailed', status: 'reopened')
    system_movement = cuadre.movimientos.create!(
      movement_group: 'other_payment_methods', payment_method: 'bank_transfer',
      description: 'Cliente contado', reference: 'E320000021299', amount: 10,
      source_key: 'payment:901'
    )
    manual_movement = cuadre.movimientos.create!(
      movement_group: 'additional_transfers', payment_method: 'bank_transfer',
      description: 'Ajuste manual', reference: 'AJ-1', amount: 25
    )

    snapshot = { invoices: [{
      source_key: 'payment:901', forma_pago: 'Transferencia', cliente_nombre: 'Cliente contado',
      numero_comprobante: 'E320000021299', total: '47605.00'
    }], receipts: [] }

    2.times { cuadre.sync_system_income_movements!(snapshot) }

    assert_equal 2, cuadre.movimientos.count
    assert_equal BigDecimal('47605.00'), system_movement.reload.amount
    assert_equal BigDecimal('25.00'), manual_movement.reload.amount
    assert_nil manual_movement.source_key
  end

  test 'elimina sugerencias de pagos que ya no forman parte del snapshot' do
    cuadre = CuadreCaja.create!(closing_date: Date.new(2026, 10, 17), closing_version: 'detailed', status: 'reopened')
    cuadre.movimientos.create!(
      movement_group: 'other_payment_methods', payment_method: 'bank_transfer',
      description: 'Cliente contado', reference: 'E320000021299', amount: 47605,
      source_key: 'payment:901'
    )

    cuadre.sync_system_income_movements!({ invoices: [], receipts: [] })

    assert_equal 0, cuadre.movimientos.count
  end
end
