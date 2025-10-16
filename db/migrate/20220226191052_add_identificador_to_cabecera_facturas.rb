class AddIdentificadorToCabeceraFacturas < ActiveRecord::Migration[6.1]
  def change
    add_column :cabecera_facturas, :identificador, :string
  end
end
