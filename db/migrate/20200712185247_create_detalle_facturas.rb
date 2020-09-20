class CreateDetalleFacturas < ActiveRecord::Migration[5.2]
  def change
    create_table :detalle_facturas do |t|
      t.references :cabecera_factura, foreign_key: true
      t.references :articulo, foreign_key: true
      t.string :unidad
      t.float :itbis
      t.float :cantidad
      t.integer :cantidad_en_unidades
      t.float :total
      t.float :precio
      t.float :costo
      t.integer :retirado
      t.integer :retirado_en_venta
      t.float :descuento_valor
      t.float :descuento_porciento

      t.timestamps
    end
  end
end
