class AddCamposToTipoArticulos < ActiveRecord::Migration[7.0]
  def change
    add_reference :tipo_articulos, :cuenta_contable_control,  foreign_key: { to_table: :cuentas_contables }, index: true, if_not_exists: true
    add_reference :tipo_articulos, :cuenta_contable_auxiliar, foreign_key: { to_table: :cuentas_contables }, index: true, if_not_exists: true
  end
end
