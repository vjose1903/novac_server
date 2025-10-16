class AddEstadoToVehiculo < ActiveRecord::Migration[5.2]
  def change
    add_column :vehiculos, :estado, :boolean
  end
end
