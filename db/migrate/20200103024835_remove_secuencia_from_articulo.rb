class RemoveSecuenciaFromArticulo < ActiveRecord::Migration[5.2]
  def change
    remove_column :articulos, :secuencia, :string
  end
end
