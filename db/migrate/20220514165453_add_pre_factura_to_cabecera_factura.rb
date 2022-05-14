class AddPreFacturaToCabeceraFactura < ActiveRecord::Migration[6.1]
  def change
		add_column :cabecera_facturas, :pre_factura, :integer
  end
end
