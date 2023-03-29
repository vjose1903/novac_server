class AddCamposToConfiguracionEntidadCuenta < ActiveRecord::Migration[7.0]
  def change
    add_column :configuraciones_entidades_cuentas, :key, :string, if_not_exists: true
  end
end
