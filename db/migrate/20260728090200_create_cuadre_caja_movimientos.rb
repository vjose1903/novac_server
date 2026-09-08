class CreateCuadreCajaMovimientos < ActiveRecord::Migration[7.0]
  def change
    create_table :cuadre_caja_movimientos do |t|
      t.references :cuadre_caja, null: false, foreign_key: true
      t.string :movement_group, null: false
      t.string :payment_method, null: false
      t.string :description, null: false
      t.string :reference
      t.string :counterparty_name
      t.string :bank_name
      t.decimal :amount, precision: 18, scale: 2, null: false, default: 0
      t.integer :position, null: false, default: 0
      t.text :notes

      t.timestamps
    end

    add_index :cuadre_caja_movimientos, [:cuadre_caja_id, :movement_group], name: 'idx_cuadre_movimientos_group'
  end
end
