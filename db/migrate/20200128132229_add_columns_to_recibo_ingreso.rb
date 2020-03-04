class AddColumnsToReciboIngreso < ActiveRecord::Migration[5.2]
  def change
    add_column :recibos_ingresos, :pago_a_tiempo, :boolean
  end
end
