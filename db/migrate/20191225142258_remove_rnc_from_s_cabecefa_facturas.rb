class RemoveRncFromSCabecefaFacturas < ActiveRecord::Migration[5.2]
  def change
    remove_column :cabecera_facturas, :medida_alerta, :string
  end
end
