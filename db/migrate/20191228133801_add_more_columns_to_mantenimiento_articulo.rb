class AddMoreColumnsToMantenimientoArticulo < ActiveRecord::Migration[5.2]
  def change
    add_column :mantenimiento_articulos, :ant_idPadre, :integer
    add_column :mantenimiento_articulos, :ant_idHijo, :integer
    add_column :mantenimiento_articulos, :ant_referenciaPadre, :integer
    add_column :mantenimiento_articulos, :ant_referenciaHijo, :integer
  end
end
