class CreateDetallesFacturasNotas < ActiveRecord::Migration[6.1]
  def change
    create_table :detalles_facturas_notas do |t|
      t.references :factura_aplicada, null: false, foreign_key: true
      t.references :articulo, null: false, foreign_key: true
      t.references :detalle_factura, null: false, foreign_key: true
      t.string :unidad
      t.float :cantidad
      t.integer :cantidad_en_unidades
      t.float :itbis
      t.float :costo
      t.float :precio
      t.float :total
      t.float :descuento

      t.timestamps
    end
  end
end
