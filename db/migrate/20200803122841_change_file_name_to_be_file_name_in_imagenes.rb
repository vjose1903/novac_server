class ChangeFileNameToBeFileNameInImagenes < ActiveRecord::Migration[5.2]
  def change
    rename_column :imagenes, :fileName, :file_name
  end
end
