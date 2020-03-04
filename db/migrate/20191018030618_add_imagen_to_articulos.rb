class AddImagenToArticulos < ActiveRecord::Migration[5.2]
  def change
    add_reference :articulos, :imagen, foreign_key: true
  end
end
