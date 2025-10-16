class AddSerieToCabeceraFactura < ActiveRecord::Migration[7.0]
  def change
    add_column :cabecera_facturas, :serie, :string, if_not_exists: true
    execute "UPDATE cabecera_facturas SET serie='normal'"
  end
end
