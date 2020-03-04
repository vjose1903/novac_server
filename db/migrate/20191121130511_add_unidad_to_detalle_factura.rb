class AddUnidadToDetalleFactura < ActiveRecord::Migration[5.2]
  def change
    add_column :detalle_facturas, :unidad, :string
  end
end
