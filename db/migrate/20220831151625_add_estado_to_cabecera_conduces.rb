class AddEstadoToCabeceraConduces < ActiveRecord::Migration[6.1]
  def change
		add_column :cabecera_conduces,   :estado, :boolean, if_not_exists: true
		execute "UPDATE cabecera_conduces SET estado=true"
  end
end
