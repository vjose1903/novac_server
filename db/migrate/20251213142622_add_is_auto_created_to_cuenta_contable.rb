class AddIsAutoCreatedToCuentaContable < ActiveRecord::Migration[7.0]
  def up
    unless column_exists?(:cuentas_contables, :is_auto_created)
      add_column :cuentas_contables,   :is_auto_created,   :boolean,   default: false
    end
  end

  def down
    if column_exists?(:cuentas_contables, :is_auto_created)
      remove_column :cuentas_contables,   :is_auto_created
    end
  end
end
