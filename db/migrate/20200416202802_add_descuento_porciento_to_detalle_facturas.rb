class AddDescuentoPorcientoToDetalleFacturas < ActiveRecord::Migration[5.2]
  def change
    add_column :detalle_facturas, :descuento_porciento, :float
    rename_column :detalle_facturas, :descuento, :descuento_valor
  end
end
