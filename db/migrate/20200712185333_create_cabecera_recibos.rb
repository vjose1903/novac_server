class CreateCabeceraRecibos < ActiveRecord::Migration[5.2]
  def change
    create_table :cabecera_recibos do |t|
      t.references :user, foreign_key: true
      t.references :cliente, foreign_key: true
      t.string :forma_pago
      t.integer :numero_recibo
      t.float :total
      t.float :devuelta

      t.timestamps
    end
  end
end
