class AddUnidadToDetalleConduce < ActiveRecord::Migration[5.2]
  def change
    add_column :detalle_conduces, :unidad, :string
  end
end
