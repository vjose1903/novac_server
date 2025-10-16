class AddCamposToVehiculo < ActiveRecord::Migration[5.2]
  def change
    add_column :vehiculos, :nombre_no_empleado, :string
    add_column :vehiculos, :apellido_no_empleado, :string
    add_column :vehiculos, :telefono_no_empleado, :string
  end
end
