class AddBrutoToCabeceraFactura < ActiveRecord::Migration[5.2]
  def change
    add_column :cabecera_facturas, :Bruto, :float
  end
end
