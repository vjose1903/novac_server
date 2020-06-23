class AddRetiradoToDetalleFactura < ActiveRecord::Migration[5.2]
  def change
    add_column :detalle_facturas, :retirado, :integer
  end
end
