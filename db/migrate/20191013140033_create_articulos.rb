class CreateArticulos < ActiveRecord::Migration[5.2]
  def change
    create_table :articulos do |t|
      t.references :imagen, foreign_key: true
      t.references :suplidor, foreign_key: true
      t.references :tipo_articulo, foreign_key: true
      t.string :nombre
      t.float :costo_principal
      t.float :precio_principal
      t.float :existencia
      t.integer :aviso_existencia
      t.string :codigo
      t.date :fecha_ingreso
      t.string :medida
      t.boolean :is_detallable
      t.string :medida_alerta
      t.boolean :calcular_itbis
      t.boolean :estado
      t.boolean :is_combo
      t.float :otros_costos
      t.string :vendido_en

      t.timestamps
    end
  end
end
