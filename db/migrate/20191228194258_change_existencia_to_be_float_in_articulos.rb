class ChangeExistenciaToBeFloatInArticulos < ActiveRecord::Migration[5.2]
  def change
    change_column :articulos, :existencia, :float
  end
end
