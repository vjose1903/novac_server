class AddMedidaToMovimientosInventario < ActiveRecord::Migration[5.2]
  def change
    add_column :movimientos_inventarios, :medida, :string
  end
end
