class AddFechaCanceladoToTrabajo < ActiveRecord::Migration[5.2]
  def change
    add_column :trabajos, :fecha_cancelado, :datetime
  end
end
