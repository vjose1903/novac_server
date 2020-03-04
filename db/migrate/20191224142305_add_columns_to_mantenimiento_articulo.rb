class AddColumnsToMantenimientoArticulo < ActiveRecord::Migration[5.2]
  def change
    add_column :mantenimiento_articulos, :ant_medidaPadre, :string
    add_column :mantenimiento_articulos, :ant_costoPadre, :float
    add_column :mantenimiento_articulos, :ant_precioPadre, :float
    add_column :mantenimiento_articulos, :ant_cantidadPadre, :integer
    add_column :mantenimiento_articulos, :ant_medidaHijo, :string
    add_column :mantenimiento_articulos, :ant_costoHijo, :float
    add_column :mantenimiento_articulos, :ant_precioHijo, :float
    add_column :mantenimiento_articulos, :ant_cantidadHijo, :integer
  end
end
