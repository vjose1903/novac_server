class ExtendCuadreCajasForDetailedClosings < ActiveRecord::Migration[7.0]
  def change
    add_column :cuadre_cajas, :closing_date, :date
    add_column :cuadre_cajas, :status, :string, null: false, default: 'draft'
    add_column :cuadre_cajas, :closing_version, :string, null: false, default: 'legacy'
    add_column :cuadre_cajas, :source_type, :string, null: false, default: 'system'
    add_column :cuadre_cajas, :currency_code, :string, null: false, default: 'DOP'

    add_reference :cuadre_cajas, :prepared_by, foreign_key: { to_table: :users }
    add_reference :cuadre_cajas, :reviewed_by, foreign_key: { to_table: :users }
    add_reference :cuadre_cajas, :approved_by, foreign_key: { to_table: :users }
    add_reference :cuadre_cajas, :submitted_by, foreign_key: { to_table: :users }
    add_reference :cuadre_cajas, :rejected_by, foreign_key: { to_table: :users }
    add_reference :cuadre_cajas, :reopened_by, foreign_key: { to_table: :users }

    add_column :cuadre_cajas, :submitted_at, :datetime
    add_column :cuadre_cajas, :reviewed_at, :datetime
    add_column :cuadre_cajas, :approved_at, :datetime
    add_column :cuadre_cajas, :rejected_at, :datetime
    add_column :cuadre_cajas, :reopened_at, :datetime

    add_column :cuadre_cajas, :local_bills_total, :decimal, precision: 18, scale: 2, null: false, default: 0
    add_column :cuadre_cajas, :local_coins_total, :decimal, precision: 18, scale: 2, null: false, default: 0
    add_column :cuadre_cajas, :foreign_currency_total, :decimal, precision: 18, scale: 2, null: false, default: 0
    add_column :cuadre_cajas, :physical_cash_total, :decimal, precision: 18, scale: 2, null: false, default: 0
    add_column :cuadre_cajas, :other_payment_methods_total, :decimal, precision: 18, scale: 2, null: false, default: 0
    add_column :cuadre_cajas, :additional_transfers_total, :decimal, precision: 18, scale: 2, null: false, default: 0
    add_column :cuadre_cajas, :operational_total, :decimal, precision: 18, scale: 2, null: false, default: 0
    add_column :cuadre_cajas, :final_consumer_invoices_total, :decimal, precision: 18, scale: 2, null: false, default: 0
    add_column :cuadre_cajas, :income_receipts_total, :decimal, precision: 18, scale: 2, null: false, default: 0
    add_column :cuadre_cajas, :system_income_total, :decimal, precision: 18, scale: 2, null: false, default: 0
    add_column :cuadre_cajas, :difference_amount, :decimal, precision: 18, scale: 2, null: false, default: 0
    add_column :cuadre_cajas, :reconciliation_tolerance, :decimal, precision: 18, scale: 2, null: false, default: 0
    add_column :cuadre_cajas, :considered_balanced, :boolean, null: false, default: false

    add_column :cuadre_cajas, :system_income_details, :jsonb, null: false, default: {}
    add_column :cuadre_cajas, :notes, :text
    add_column :cuadre_cajas, :rejection_reason, :text
    add_column :cuadre_cajas, :reopen_reason, :text

    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          UPDATE cuadre_cajas
          SET closing_date = COALESCE(fecha_equivalente::date, created_at::date, CURRENT_DATE),
              prepared_by_id = user_id,
              status = 'approved',
              closing_version = 'legacy',
              source_type = 'system',
              system_income_total = COALESCE(total_general, 0),
              operational_total = COALESCE(total_general, 0),
              final_consumer_invoices_total = COALESCE(total_venta_contado, 0),
              income_receipts_total = COALESCE(total_recibo_ingreso, 0),
              difference_amount = 0,
              considered_balanced = true
        SQL
      end
    end

    change_column_null :cuadre_cajas, :closing_date, false
    add_index :cuadre_cajas, :closing_date, unique: true, where: "status <> 'cancelled'", name: 'idx_cuadre_cajas_unique_active_closing_date'
  end
end
