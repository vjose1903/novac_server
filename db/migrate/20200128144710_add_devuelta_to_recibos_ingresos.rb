class AddDevueltaToRecibosIngresos < ActiveRecord::Migration[5.2]
  def change
    add_column :recibos_ingresos, :devuelta, :float
  end
end
