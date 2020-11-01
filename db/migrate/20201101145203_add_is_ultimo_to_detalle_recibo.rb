class AddIsUltimoToDetalleRecibo < ActiveRecord::Migration[5.2]
  def change
    add_column :detalle_recibos, :is_ultimo, :boolean
  end
end
