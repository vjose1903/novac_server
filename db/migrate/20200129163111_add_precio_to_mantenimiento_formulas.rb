class AddPrecioToMantenimientoFormulas < ActiveRecord::Migration[5.2]
  def change
    add_column :mantenimiento_formulas, :precio, :float
  end
end
