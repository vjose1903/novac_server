class AddKeyToTipoFacturas < ActiveRecord::Migration[7.0]
  def up
    unless column_exists?(:tipo_facturas, :key)
      add_column :tipo_facturas,   :key,   :string
    end
  end

  def down
    if column_exists?(:tipo_facturas, :key)
      remove_column :tipo_facturas,   :key
    end
  end
end
