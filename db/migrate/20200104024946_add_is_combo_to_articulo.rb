class AddIsComboToArticulo < ActiveRecord::Migration[5.2]
  def change
    add_column :articulos, :isCombo, :boolean
  end
end
