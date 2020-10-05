class ChangeCantidadToBeFloatInDetalleConduce < ActiveRecord::Migration[5.2]
  def change
    change_column :detalle_conduces, :cantidad, :float
  end
end
