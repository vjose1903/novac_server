class AddCostoYGastoToCabeceraFactura < ActiveRecord::Migration[5.2]
  def change
    add_column :cabecera_facturas, :costoYgasto, :string
  end
end
