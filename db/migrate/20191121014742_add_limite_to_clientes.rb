class AddLimiteToClientes < ActiveRecord::Migration[5.2]
  def change
    add_column :clientes, :limite_credito, :integer
  end
end
