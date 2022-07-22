class ChangeSecuencuaToBeStringInTables < ActiveRecord::Migration[6.1]
  def change
		change_column :mantenimiento_articulos, :secuencia, :string
		change_column :mantenimiento_formulas, :secuencia, :string
  end
end
