class CreateDetalleRecibos < ActiveRecord::Migration[5.2]
  def change
    create_table :detalle_recibos do |t|
      t.references :recibos_ingreso, foreign_key: true
      t.references :cabecera_factura, foreign_key: true
      t.boolean :pago_total
      t.float :deposito
      t.timestamps
    end
  end
end
