class AddAgotadoToArticulo < ActiveRecord::Migration[5.2]
  def change
    add_column :articulos, :agotado, :boolean
  end
end
