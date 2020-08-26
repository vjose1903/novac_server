class CreateHistoricoArticulos < ActiveRecord::Migration[5.2]
  def change
    create_table :historico_articulos do |t|
      t.references :articulo, foreign_key: true
      t.references :suplidor, foreign_key: true
      t.references :marca, foreign_key: true
      t.references :modelo, foreign_key: true
      t.references :tipo_articulo, foreign_key: true
      t.references :user, foreign_key: true
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
      t.integer :secuencia
      t.boolean :agotado
      t.string :medida_hijo
      t.float :costo_hijo
      t.float :precio_hijo
      t.integer :cantidad_hijo
      t.integer :referencia_hijo
      t.string :medida_padre
      t.float :costo_padre
      t.float :precio_padre
      t.integer :cantidad_padre
      t.integer :referencia_padre

      t.timestamps
    end
  end
end
