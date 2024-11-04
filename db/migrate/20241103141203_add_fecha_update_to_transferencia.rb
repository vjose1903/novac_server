class AddFechaUpdateToTransferencia < ActiveRecord::Migration[7.0]
  def change
    add_column :transferencias, :fecha_update, :date, if_not_exists: true
  end
end
