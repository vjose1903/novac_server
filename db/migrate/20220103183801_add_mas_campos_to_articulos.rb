class AddMasCamposToArticulos < ActiveRecord::Migration[6.1]
  def change
    add_index :articulos, [:estado, :nombre], unique: true, where: "(estado = true)"
  end
end
