class AddTieneNotaToCabeceraFactura < ActiveRecord::Migration[5.2]
  def change
    add_column :cabecera_facturas, :tiene_nota, :boolean
  end
end
