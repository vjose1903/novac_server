class CreateRecibosIngresos < ActiveRecord::Migration[5.2]
  def change
    create_table :recibos_ingresos do |t|
      t.references :user, foreign_key: true
      t.float :total
      t.string :forma_pago
      t.integer :numero_recibo
      t.timestamps
    end
  end
end
