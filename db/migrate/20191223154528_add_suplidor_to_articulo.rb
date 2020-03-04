class AddSuplidorToArticulo < ActiveRecord::Migration[5.2]
  def change
    add_reference :articulos, :suplidor, foreign_key: true
  end
end
