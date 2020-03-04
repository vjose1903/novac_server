class CreateArticulos < ActiveRecord::Migration[5.2]
  def change
    create_table :articulos do |t|
      t.references :tipo_articulo, foreign_key: true
      t.string :nombre
      t.float :costo_principal
      t.float :precio_principal
      t.integer :existencia
      t.integer :secuencia
      t.string :codigo
      t.date :fecha_ingreso
      t.string :medida
      t.boolean :is_detallable

      t.timestamps
    end
  end
end
