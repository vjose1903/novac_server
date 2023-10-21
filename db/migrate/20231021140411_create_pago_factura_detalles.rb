class CreatePagoFacturaDetalles < ActiveRecord::Migration[7.0]
  def change
    create_table :pago_factura_detalles do |t|
      t.references :pago_factura,     null: false, foreign_key: true
      t.references :cabecera_factura, null: false, foreign_key: true
      t.float   :balance_anterior_factura
      t.float   :balance_factura
      t.float   :deposito
      t.boolean :is_ultimo
      t.string  :descripcion
      t.boolean :pago_a_tiempo

      t.timestamps
    end
  end
end
