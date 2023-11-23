class AddIsValidatedToCabezaAsientoContable < ActiveRecord::Migration[7.0]
  def change
    reversible do |dir|
      dir.up do
        add_column :cabezas_asientos_contables, :is_validated, :boolean
      end

      dir.down do
        remove_column :cabezas_asientos_contables, :is_validated
      end
    end
  end
end
