class AddCalcularSacoToMantenimientoArticulos < ActiveRecord::Migration[5.2]
  def change
    add_column :mantenimiento_articulos, :calcular_saco, :boolean
  end
end
