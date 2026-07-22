class AddIsExternalToCabeceraFactura < ActiveRecord::Migration[7.0]
  def up
    unless column_exists?(:cabecera_facturas, :is_external)
      add_column :cabecera_facturas, :is_external, :boolean, default: false
    end

    CabeceraFactura.where(is_external: nil).update_all(is_external: false)
  end

  def down
    if column_exists?(:cabecera_facturas, :is_external)
      remove_column :cabecera_facturas, :is_external
    end
  end
end
