class AddMedidaAlertaToCabeceraFactura < ActiveRecord::Migration[5.2]
  def change
    add_column :cabecera_facturas, :medida_alerta, :string
  end
end
