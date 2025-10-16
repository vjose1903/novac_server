class AddEstadoToReciboIngreso < ActiveRecord::Migration[5.2]
  def change
    add_column :recibos_ingresos, :estado, :boolean
  end
end
