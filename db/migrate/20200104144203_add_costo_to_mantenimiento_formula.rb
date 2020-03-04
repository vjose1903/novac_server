class AddCostoToMantenimientoFormula < ActiveRecord::Migration[5.2]
  def change
    add_column :mantenimiento_formulas, :costo, :float
  end
end
