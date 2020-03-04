class AddDevueltaToCabeceraFacturas < ActiveRecord::Migration[5.2]
  def change
    add_column :cabecera_facturas, :devuelta, :float
  end
end
