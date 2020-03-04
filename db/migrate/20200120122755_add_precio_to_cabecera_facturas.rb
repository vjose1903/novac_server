class AddPrecioToCabeceraFacturas < ActiveRecord::Migration[5.2]
  def change
    add_column :cabecera_facturas, :precio, :float
  end
end
