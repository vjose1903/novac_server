class CreateDetalleFacturas < ActiveRecord::Migration[5.2]
  def change
    create_table :detalle_facturas do |t|
      t.references :cabecera_factura, foreign_key: true
      t.references :articulo, foreign_key: true
      t.integer :cantidad
      t.integer :total
      t.integer :descuento
      t.integer :itbis

      t.timestamps
    end
  end
end
