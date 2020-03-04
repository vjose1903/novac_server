class AddClienteToRecibosIngresos < ActiveRecord::Migration[5.2]
  def change
    add_reference :recibos_ingresos, :cliente, foreign_key: true
  end
end
