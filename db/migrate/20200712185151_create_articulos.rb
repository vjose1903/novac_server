class CreateArticulos < ActiveRecord::Migration[5.2]
  def change
    create_table :articulos do |t|
      t.references :suplidor, foreign_key: true
      t.references :marca, foreign_key: true
      t.references :modelo, foreign_key: true
      t.references :tipo_articulo, foreign_key: true
      t.string :identificador
      t.string :nombre
      t.string :color
      t.float :costo_principal
      t.float :precio_principal
      t.integer :existencia
      t.string :codigo
      t.string :medida
      t.boolean :is_detallable
      t.integer :aviso_existencia
      t.string :medida_alerta
      t.boolean :estado
      t.boolean :is_combo
      t.boolean :unico
      t.boolean :agotado

      t.timestamps
    end
  end
end
