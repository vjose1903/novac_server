class ChangeColumnOrigenToImagen < ActiveRecord::Migration[7.0]
  def change

    if column_exists?(:imagenes, :origen_id) && column_exists?(:imagenes, :origen_type)
      rename_column :imagenes, :origen_id,   :origen_img_id
      rename_column :imagenes, :origen_type, :origen_img_type
    else
      puts "No se puede renombrar la columna porque no existe en la tabla imagenes.".red
    end
  end
end
