class AddCamposCuentasBancarias < ActiveRecord::Migration[7.0]
  def change
    add_column :cuentas_bancarias,   :balance_inicial_banco, :float,    default: 0, if_not_exists: true
    add_column :cuentas_bancarias,   :balance_inicial_libro, :float,    default: 0, if_not_exists: true
  end
end
