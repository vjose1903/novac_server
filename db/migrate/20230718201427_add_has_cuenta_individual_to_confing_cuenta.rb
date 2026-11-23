class AddHasCuentaIndividualToConfingCuenta < ActiveRecord::Migration[7.0]
  def change
    add_column :configuraciones_entidades_cuentas, :has_individual,    :boolean, if_not_exists: true
    add_column :configuraciones_entidades_cuentas, :has_categoria,     :boolean, if_not_exists: true
    add_column :configuraciones_entidades_cuentas, :has_sub_categoria, :boolean, if_not_exists: true
  end
end
