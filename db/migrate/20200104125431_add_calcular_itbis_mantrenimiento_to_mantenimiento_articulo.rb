class AddCalcularItbisMantrenimientoToMantenimientoArticulo < ActiveRecord::Migration[5.2]
  def change
    add_column :mantenimiento_articulos, :ant_calcularItbis, :boolean
  end
end
