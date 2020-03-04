class RemoveAntCantidadComboFromMantenimientoArticulo < ActiveRecord::Migration[5.2]
  def change
    remove_column :mantenimiento_articulos, :ant_cantidadCombo, :float
  end
end
