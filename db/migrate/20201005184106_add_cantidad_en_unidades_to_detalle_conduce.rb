class AddCantidadEnUnidadesToDetalleConduce < ActiveRecord::Migration[5.2]
  def change
    add_column :detalle_conduces, :cantidad_en_unidades, :integer
  end
end
