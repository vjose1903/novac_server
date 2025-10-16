class AddSerieToTipoFacturas < ActiveRecord::Migration[7.0]
  def change
    add_column :tipo_facturas, :serie, :string, if_not_exists: true
    execute "UPDATE tipo_facturas SET serie='normal'"
  end
end
