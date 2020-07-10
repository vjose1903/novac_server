class ChangeIsComboToBeIsComboInArticulos < ActiveRecord::Migration[5.2]
  def change
    rename_column :articulos, :isCombo, :is_combo
  end
end
