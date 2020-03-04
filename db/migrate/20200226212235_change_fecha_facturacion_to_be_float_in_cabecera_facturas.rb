class ChangeFechaFacturacionToBeFloatInCabeceraFacturas < ActiveRecord::Migration[5.2]
  def change
    change_column :cabecera_facturas, :fecha_facturacion, :timestamp 
  end
end
