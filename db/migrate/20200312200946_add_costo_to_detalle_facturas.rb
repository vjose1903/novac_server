class AddCostoToDetalleFacturas < ActiveRecord::Migration[5.2]
  def change
    add_column :detalle_facturas, :costo, :float
  end
end
