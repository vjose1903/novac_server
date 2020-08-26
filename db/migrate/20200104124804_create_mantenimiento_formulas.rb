class CreateMantenimientoFormulas < ActiveRecord::Migration[5.2]
  def change
    create_table :mantenimiento_formulas do |t|
      t.integer :articulo_id
      t.float :cantidad
      t.float :costo
      t.integer :secuencia
      t.integer :articulo_combo
      t.float :precio
      t.timestamps
    end
  end
end
