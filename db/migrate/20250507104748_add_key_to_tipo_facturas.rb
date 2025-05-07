class AddKeyToTipoFacturas < ActiveRecord::Migration[7.0]
  def change
    add_column :tipo_facturas, :key, :string
  end
end
