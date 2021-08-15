class AddEstadoToCostoFletes < ActiveRecord::Migration[5.2]
  def change
    add_column :costo_fletes, :estado, :boolean
  end
end
