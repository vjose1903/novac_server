class RemovePagoATiempoFromRecibosIngresos < ActiveRecord::Migration[5.2]
  def change
    remove_column :recibos_ingresos, :pago_a_tiempo, :boolean
    add_column :detalle_recibos, :pago_a_tiempo, :boolean
  end
end
