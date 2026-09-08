class AddCamposToImagen < ActiveRecord::Migration[7.0]
  def change
    add_reference :imagenes, :origen, polymorphic: true, index: true
    remove_column :imagenes, :path, if_exists: true
  end
end
