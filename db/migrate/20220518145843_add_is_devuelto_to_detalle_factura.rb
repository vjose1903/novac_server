class AddIsDevueltoToDetalleFactura < ActiveRecord::Migration[6.1]
  def change
		add_column :detalle_facturas, :is_devuelto, :boolean
		execute "UPDATE detalle_facturas SET is_devuelto=false"
  end
end
