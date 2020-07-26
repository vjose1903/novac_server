class AddCamposToTrabajo < ActiveRecord::Migration[5.2]
  def change
    add_column :trabajos, :empezado, :boolean
    add_column :trabajos, :terminado, :boolean
    add_column :trabajos, :estado, :boolean
  end
end
