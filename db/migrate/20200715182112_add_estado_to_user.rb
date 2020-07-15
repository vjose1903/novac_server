class AddEstadoToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :estado, :boolean
  end
end
