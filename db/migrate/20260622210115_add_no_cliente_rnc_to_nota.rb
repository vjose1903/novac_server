class AddNoClienteRncToNota < ActiveRecord::Migration[7.0]
  def up
    unless column_exists?(:notas, :no_cliente_rnc)
      add_column :notas, :no_cliente_rnc, :string, null: true
    end
  end

  def down
    if column_exists?(:notas, :no_cliente_rnc)
      remove_column :notas, :no_cliente_rnc
    end
  end
end
