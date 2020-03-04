class AddAdelantadaToCabeceraFacturas < ActiveRecord::Migration[5.2]
  def change
    add_column :cabecera_facturas, :adelantada, :boolean
  end
end
