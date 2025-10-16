class AddAnioToVehiculo < ActiveRecord::Migration[5.2]
  def change
    add_column :vehiculos, :anio, :string
  end
end
