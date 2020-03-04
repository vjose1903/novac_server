class AddMedidaAlertaToMantenimientoArticulo < ActiveRecord::Migration[5.2]
  def change
    add_column :mantenimiento_articulos, :ant_medidaAlerta, :string
  end
end
