class AddIsDefectuosoToDetalleFactura < ActiveRecord::Migration[6.1]
  def change
		add_column :detalle_facturas, :is_defectuoso, :boolean
		execute "UPDATE detalle_facturas SET is_defectuoso=false"
  end
end
