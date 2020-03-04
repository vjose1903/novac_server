class AddVendedorIdToCabeceraFacturas < ActiveRecord::Migration[5.2]
  def change
    add_column :cabecera_facturas, :vendedor_id, :integer
  end
end
