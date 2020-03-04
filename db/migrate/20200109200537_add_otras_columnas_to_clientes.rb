class AddOtrasColumnasToClientes < ActiveRecord::Migration[5.2]
  def change
    add_column :clientes, :maximo_credito, :float
    add_column :clientes, :vendedor_id, :integer
  end
end
