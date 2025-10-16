class AddIsMateriaPrimaToArticulo < ActiveRecord::Migration[5.2]
  def change
    add_column :articulos, :is_materia_prima, :boolean
    add_column :mantenimiento_articulos, :is_materia_prima, :boolean
  end
end
