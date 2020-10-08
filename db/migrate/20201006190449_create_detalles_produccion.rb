class CreateDetallesProduccion < ActiveRecord::Migration[5.2]
  def change
    create_table :detalles_produccion do |t|
      t.references :produccion, foreign_key: true
      t.references :articulo, foreign_key: true
      t.float :cantidad
      t.integer :cantidad_en_unidades
      t.string :medida

      t.timestamps
    end
  end
end
