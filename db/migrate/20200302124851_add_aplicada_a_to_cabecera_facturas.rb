class AddAplicadaAToCabeceraFacturas < ActiveRecord::Migration[5.2]
  def change
    add_column :cabecera_facturas, :aplicada_a, :string
  end
end
