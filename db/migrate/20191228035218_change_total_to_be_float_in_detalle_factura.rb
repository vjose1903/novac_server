class ChangeTotalToBeFloatInDetalleFactura < ActiveRecord::Migration[5.2]
  def change
    change_column :detalle_facturas, :total, :float
    change_column :detalle_facturas, :cantidad, :float
    change_column :detalle_facturas, :total, :float
    change_column :detalle_facturas, :descuento, :float
    change_column :detalle_facturas, :itbis, :float
  end
end
