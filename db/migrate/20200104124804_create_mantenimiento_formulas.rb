class CreateMantenimientoFormulas < ActiveRecord::Migration[5.2]
  def change
    create_table :mantenimiento_formulas do |t|
      t.references :mantenimiento_articulos, foreign_key: true
      t.integer :articulo_id
      t.float :cantidad

      t.timestamps
    end
  end
end
