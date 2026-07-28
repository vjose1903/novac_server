class CreateCuadreCajaDenominaciones < ActiveRecord::Migration[7.0]
  def change
    create_table :cuadre_caja_denominaciones do |t|
      t.references :cuadre_caja, null: false, foreign_key: true
      t.string :denomination_type, null: false
      t.string :currency_code, null: false, default: 'DOP'
      t.decimal :denomination_value, precision: 18, scale: 2, null: false
      t.decimal :quantity, precision: 18, scale: 2, null: false, default: 0
      t.decimal :exchange_rate, precision: 18, scale: 6, null: false, default: 1
      t.decimal :foreign_amount, precision: 18, scale: 2, null: false, default: 0
      t.decimal :local_currency_total, precision: 18, scale: 2, null: false, default: 0
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :cuadre_caja_denominaciones,
              [:cuadre_caja_id, :denomination_type, :currency_code, :denomination_value],
              unique: true,
              name: 'idx_cuadre_denominaciones_unique'
  end
end
