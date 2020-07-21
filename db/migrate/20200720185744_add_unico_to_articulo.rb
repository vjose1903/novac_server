class AddUnicoToArticulo < ActiveRecord::Migration[5.2]
  def change
    add_column :articulos, :unico, :boolean
  end
end
