class AddTipoReciboToRecibosIngreso < ActiveRecord::Migration[5.2]
  def change
    add_reference :recibos_ingresos, :tipo_recibo, foreign_key: true
  end
end
