class CreateCabeceraFacturas < ActiveRecord::Migration[5.2]
  def change
    create_table :cabecera_facturas do |t|
      t.references :tipo_factura, foreign_key: true
      t.references :suplidor, foreign_key: true
      t.references :cliente, foreign_key: true
      t.references :user, foreign_key: true
      t.date :fecha_facturacion
      t.date :fecha_vencimiento
      t.date :fecha_valida
      t.string :numero_comprobante
      t.integer :numero_factura
      t.string :condicion
      t.string :forma_pago
      t.integer :total_factura
      t.integer :itbis
      t.integer :descuento
      t.boolean :estado
      t.string :tipo

      t.timestamps
    end
  end
end
