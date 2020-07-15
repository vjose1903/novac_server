class CreateCabeceraFacturas < ActiveRecord::Migration[5.2]
  def change
    create_table :cabecera_facturas do |t|
      t.references :user, foreign_key: true
      t.references :cliente, foreign_key: true
      t.string :forma_pago
      t.integer :numero_factura
      t.float :total_factura
      t.boolean :pagada
      t.float :balance
      t.boolean :tiene_nota
      t.float :devuelta
      t.string :noCliente_nombre
      t.string :noCliente_direccion

      t.timestamps
    end
  end
end
