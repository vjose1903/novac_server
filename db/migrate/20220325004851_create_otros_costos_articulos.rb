class CreateOtrosCostosArticulos < ActiveRecord::Migration[6.1]
  def change
    create_table :otros_costos_articulos do |t|
      t.references :articulo, null: false, foreign_key: true
      t.references :otro_costo, null: false, foreign_key: true

      t.timestamps
    end
  end
end
