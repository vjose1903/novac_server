class CreateDetalleConduces < ActiveRecord::Migration[5.2]
  def change
    create_table :detalle_conduces do |t|
      t.references :cabecera_conduce, foreign_key: true
      t.references :detalle_factura, foreign_key: true
      t.references :articulo, foreign_key: true
      t.integer :cantidad
      t.string :unidad

      t.timestamps
    end
  end
end
