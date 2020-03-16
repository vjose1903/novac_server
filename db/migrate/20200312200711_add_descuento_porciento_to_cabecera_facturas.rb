class AddDescuentoPorcientoToCabeceraFacturas < ActiveRecord::Migration[5.2]
  def change
    add_column :cabecera_facturas, :descuento_porciento, :float
    rename_column :cabecera_facturas, :descuento, :descuento_valor
  end
end
