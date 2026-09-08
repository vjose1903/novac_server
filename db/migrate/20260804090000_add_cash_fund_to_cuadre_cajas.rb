class AddCashFundToCuadreCajas < ActiveRecord::Migration[7.0]
  def change
    add_column :cuadre_cajas, :opening_cash_fund, :decimal, precision: 18, scale: 2, null: false, default: 0
    add_column :cuadre_cajas, :next_day_cash_fund, :decimal, precision: 18, scale: 2, null: false, default: 0
    add_column :cuadre_cajas, :expected_total, :decimal, precision: 18, scale: 2, null: false, default: 0
  end
end
