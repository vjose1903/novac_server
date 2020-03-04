class ChangeTotalToBeDoubleInCabeceraFactura < ActiveRecord::Migration[5.2]
  def change
    change_column :cabecera_facturas, :total_factura, :float
    change_column :cabecera_facturas, :itbis, :float
    change_column :cabecera_facturas, :descuento, :float
  end
end
