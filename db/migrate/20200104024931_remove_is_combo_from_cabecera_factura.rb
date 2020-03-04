class RemoveIsComboFromCabeceraFactura < ActiveRecord::Migration[5.2]
  def change
    remove_column :cabecera_facturas, :isCombo, :boolean
  end
end
