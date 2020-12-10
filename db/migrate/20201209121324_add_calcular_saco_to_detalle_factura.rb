class AddCalcularSacoToDetalleFactura < ActiveRecord::Migration[5.2]
  def change
    add_column :detalle_facturas, :calcular_saco, :boolean
    add_column :articulos, :calcular_saco, :boolean
  end
end
