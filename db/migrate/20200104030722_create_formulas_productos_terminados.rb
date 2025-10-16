class CreateFormulasProductosTerminados < ActiveRecord::Migration[5.2]
  def change
    create_table :formulas_productos_terminados do |t|
      t.references :articulo, foreign_key: true
      t.float :cantidad
      t.float :costo
      t.integer :articulo_combo
      t.float :precio
      t.timestamps
    end
  end
end
