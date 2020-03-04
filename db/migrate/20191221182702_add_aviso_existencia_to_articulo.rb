class AddAvisoExistenciaToArticulo < ActiveRecord::Migration[5.2]
  def change
    add_column :articulos, :aviso_existencia, :integer
  end
end
