class AddFechaViajesToCabeceraFacturas < ActiveRecord::Migration[5.2]
  def change
    add_column :cabecera_facturas, :fecha_viaje, :datetime
  end
end
