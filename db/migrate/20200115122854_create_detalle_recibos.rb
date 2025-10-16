class CreateDetalleRecibos < ActiveRecord::Migration[5.2]
  def change
    create_table :detalle_recibos do |t|
      t.references :recibos_ingreso, foreign_key: true
      t.references :cabecera_factura, foreign_key: true
      t.float :balance_factura
      t.float :balance_anterior_factura
      t.boolean :pago_total
      t.float :deposito
      t.string :descripcion
      t.boolean :pago_a_tiempo
      t.boolean :is_ultimo
      t.timestamps
    end
  end
end
