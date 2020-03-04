class RemovePrecioFromCabeceraFacturas < ActiveRecord::Migration[5.2]
  def change
    remove_column :cabecera_facturas, :precio, :float
    add_column :detalle_facturas, :precio, :float
  end
end
