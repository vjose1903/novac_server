class AddMoreColumnsMantrenimientoToMantenimientoArticulo < ActiveRecord::Migration[5.2]
  def change
    add_column :mantenimiento_articulos, :ant_isCombo, :boolean
    add_column :mantenimiento_articulos, :ant_cantidadCombo, :float
  end
end
