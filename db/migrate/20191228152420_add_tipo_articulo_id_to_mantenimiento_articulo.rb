class AddTipoArticuloIdToMantenimientoArticulo < ActiveRecord::Migration[5.2]
  def change
    add_column :mantenimiento_articulos, :ant_tipoArticuloId, :integer
  end
end
