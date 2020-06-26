class AddRetiradoEnLaVentaToDetalleFactura < ActiveRecord::Migration[5.2]
  def change
    add_column :detalle_facturas, :retirado_en_venta, :integer
  end
end
