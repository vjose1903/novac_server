class AddCotizacionToCabeceraFactura < ActiveRecord::Migration[7.0]
  def change
		add_column :cabecera_facturas, :cotizacion, :integer
  end
end
