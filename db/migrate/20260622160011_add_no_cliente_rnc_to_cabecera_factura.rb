class AddNoClienteRncToCabeceraFactura < ActiveRecord::Migration[7.0]
  def up
    unless column_exists?(:cabecera_facturas, :NoCliente_rnc)
      add_column :cabecera_facturas, :NoCliente_rnc, :string, null: true
    end
  end

  def down
    if column_exists?(:cabecera_facturas, :NoCliente_rnc)
      remove_column :cabecera_facturas, :NoCliente_rnc
    end
  end
end
