class AddNoClienteToCabeceraFactura < ActiveRecord::Migration[5.2]
  def change
    add_column :cabecera_facturas, :NoCliente_nombre, :string
    add_column :cabecera_facturas, :NoCliente_direccion, :string
  end
end
