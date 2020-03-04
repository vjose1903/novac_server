class AddIsComboToCabeceraFactura < ActiveRecord::Migration[5.2]
  def change
    add_column :cabecera_facturas, :isCombo, :boolean
  end
end
