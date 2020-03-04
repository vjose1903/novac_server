class AddSecuenciaToMantenimientoFormula < ActiveRecord::Migration[5.2]
  def change
    add_column :mantenimiento_formulas, :secuencia, :integer
    add_column :mantenimiento_articulos, :secuencia, :integer
  end
end
