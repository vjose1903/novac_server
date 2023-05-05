class ChangeCuentaControlToReference < ActiveRecord::Migration[7.0]

  def up
    add_column :cuentas_contables, :cuenta_control_id, :bigint
    add_foreign_key :cuentas_contables, :cuentas_contables, column: :cuenta_control_id, foreign_key: { to_table: :cuentas_contables }

    CuentaContable.reset_column_information

    reversible do |dir|
      dir.up do
        CuentaContable.find_each do | cuenta |
          cuenta.update_attribute(:cuenta_control_id, cuenta.cuenta_control)
        end
      end
    end

    remove_column :cuentas_contables, :cuenta_control, :integer
  end

  def down
    add_column :cuentas_contables, :cuenta_control, :integer

    reversible do |dir|
      dir.up do
        CuentaContable.find_each do | cuenta |
          cuenta.update_attribute(:cuenta_control, cuenta.cuenta_control_id)
        end
      end
    end

    remove_foreign_key :cuentas_contables, column: :cuenta_control_id
    remove_column :cuentas_contables, :cuenta_control_id, :bigint
  end

end