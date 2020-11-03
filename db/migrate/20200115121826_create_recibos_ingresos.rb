class CreateRecibosIngresos < ActiveRecord::Migration[5.2]
  def change
    create_table :recibos_ingresos do |t|
      t.references :user, foreign_key: true
      t.references :tipo_factura, foreign_key: true
      t.references :cliente, foreign_key: true
      t.references :vehiculo, foreign_key: true
      t.float :total
      t.integer :chofer
      t.string :forma_pago
      t.integer :numero_recibo
      t.integer :incidencia
      t.float :devuelta
      t.datetime :fecha_equivalente

      t.timestamps
    end
  end
end
