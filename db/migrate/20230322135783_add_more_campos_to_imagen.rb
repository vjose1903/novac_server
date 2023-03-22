class AddMoreCamposToImagen < ActiveRecord::Migration[7.0]
  def change
    add_column :imagenes, :file_hash, :string, if_not_exists: true
  end
end
