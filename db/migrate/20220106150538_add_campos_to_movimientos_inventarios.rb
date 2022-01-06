class AddCamposToMovimientosInventarios < ActiveRecord::Migration[6.1]
  def change
    add_column :movimientos_inventarios, :cantidad_en_unidades, :integer
  end
end
