class AddTipoSalidaToMovimientoInventario < ActiveRecord::Migration[5.2]
  def change
    add_column :movimientos_inventarios, :tipo_salida, :string
  end
end
