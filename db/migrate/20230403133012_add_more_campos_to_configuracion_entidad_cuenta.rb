class AddMoreCamposToConfiguracionEntidadCuenta < ActiveRecord::Migration[7.0]
  def change
		add_column :configuraciones_entidades_cuentas, :is_nacional, :boolean, if_not_exists: true
  end
end
