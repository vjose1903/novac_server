class AddMedidaAlertaToArticulos < ActiveRecord::Migration[5.2]
  def change
    add_column :articulos, :medida_alerta, :string
  end
end
