class CreateCabeceraFacturas < ActiveRecord::Migration[5.2]
  def change
    create_table :cabecera_facturas do |t|
      t.references :user, foreign_key: true
      t.references :cliente, foreign_key: true
      t.references :tipo_factura, foreign_key: true
      t.integer :numero_factura
      t.float :bruto
      t.float :itbis
      t.float :descuento
      t.float :total_factura
      t.float :devuelta
      t.float :balance
      t.boolean :pagada
      t.boolean :tiene_nota
      t.boolean :estado
      t.boolean :is_nota
      t.date :fecha_vencimiento
      t.date :fecha_facturacion
      t.string :forma_pago
      t.string :condicion
      t.string :noCliente_nombre
      t.string :noCliente_direccion
      t.string :noCliente_telefono
      t.string :numero_comprobante

      t.timestamps
    end
  end
end
