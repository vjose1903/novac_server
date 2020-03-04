class AddBalanceToCabeceraFacturas < ActiveRecord::Migration[5.2]
  def change
    add_column :cabecera_facturas, :balance, :float
  end
end
