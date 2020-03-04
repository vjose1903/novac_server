class CreateFormulasProductosTerminados < ActiveRecord::Migration[5.2]
  def change
    create_table :formulas_productos_terminados do |t|
      t.references :articulos, foreign_key: true
      t.float :cantidad

      t.timestamps
    end
  end
end
