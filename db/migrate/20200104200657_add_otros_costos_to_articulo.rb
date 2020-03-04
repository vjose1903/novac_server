class AddOtrosCostosToArticulo < ActiveRecord::Migration[5.2]
  def change
    add_column :articulos, :otros_costos, :float
  end
end
