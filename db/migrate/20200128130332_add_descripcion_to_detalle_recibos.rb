class AddDescripcionToDetalleRecibos < ActiveRecord::Migration[5.2]
  def change
    add_column :detalle_recibos, :descripcion, :string
  end
end
