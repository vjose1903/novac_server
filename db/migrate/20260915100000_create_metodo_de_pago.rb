class CreateMetodoDePago < ActiveRecord::Migration[5.2]
  def up
    create_table :metodo_de_pago do |t|
      t.string :metodo_de_pago_able_type, null: false
      t.bigint :metodo_de_pago_able_id, null: false
      t.string :forma_pago, null: false
      t.decimal :monto, precision: 15, scale: 2, null: false, default: 0
      t.timestamps
    end

    add_index :metodo_de_pago, [:metodo_de_pago_able_type, :metodo_de_pago_able_id], name: 'index_metodo_de_pago_on_able'
    add_check_constraint :metodo_de_pago, 'monto >= 0', name: 'metodo_de_pago_monto_no_negativo'

    execute <<~SQL.squish
      INSERT INTO metodo_de_pago (metodo_de_pago_able_type, metodo_de_pago_able_id, forma_pago, monto, created_at, updated_at)
      SELECT 'CabeceraFactura', id, COALESCE(NULLIF(BTRIM(forma_pago), ''), 'Efectivo'), GREATEST(COALESCE(total_factura, 0)::numeric(15,2), 0), created_at, updated_at FROM cabecera_facturas
    SQL
    execute <<~SQL.squish
      INSERT INTO metodo_de_pago (metodo_de_pago_able_type, metodo_de_pago_able_id, forma_pago, monto, created_at, updated_at)
      SELECT 'RecibosIngreso', id, COALESCE(NULLIF(BTRIM(forma_pago), ''), 'Efectivo'), COALESCE(total, 0)::numeric(15,2), created_at, updated_at FROM recibos_ingresos
    SQL
  end

  def down
    drop_table :metodo_de_pago
  end
end
