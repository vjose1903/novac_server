class AddBalanceToClientes < ActiveRecord::Migration[5.2]
  def change
    add_column :clientes, :balance, :float
  end
end
