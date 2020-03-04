class AddIsNotaToCabeceraFacturas < ActiveRecord::Migration[5.2]
  def change
    add_column :cabecera_facturas, :is_nota, :boolean
  end
end
