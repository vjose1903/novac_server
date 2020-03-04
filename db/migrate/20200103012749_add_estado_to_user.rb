class AddEstadoToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :estado, :boolean
    add_column :suplidores, :estado, :boolean
    add_column :articulos, :estado, :boolean
    add_column :clientes, :estado, :boolean
  end
end
