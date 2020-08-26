class CreateContenidoArticulos < ActiveRecord::Migration[5.2]
  def change
    create_table :contenido_articulos do |t|
      t.references :articulo, foreign_key: true
      t.integer :referencia
      t.float :costo
      t.float :precio
      t.integer :cantidad
      t.string :medida
      t.string :condicion
      t.boolean :calcular_itbis
      t.timestamps
    end
  end
end
