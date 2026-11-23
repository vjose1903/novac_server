class AddFechaPrimeraConciliacionToCuentaBancaria < ActiveRecord::Migration[7.0]
  def change
    reversible do |dir|
      dir.up do
        add_column :cuentas_bancarias, :fecha_primera_conciliacion, :date
      end

      dir.down do
        remove_column :cuentas_bancarias, :fecha_primera_conciliacion
      end
    end
  end
end
