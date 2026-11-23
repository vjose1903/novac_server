class AddCanCobrarToCabeceraFactura < ActiveRecord::Migration[7.0]
  def change
		reversible do |dir|
      dir.up do
        add_column :cabecera_facturas, :can_pagar, :boolean
        execute "UPDATE cabecera_facturas SET can_pagar=false"
      end

      dir.down do
        remove_column :cabecera_facturas, :can_pagar
      end
    end
  end
end
