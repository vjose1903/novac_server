class AddHasChequeaToCuentaBancaria < ActiveRecord::Migration[7.0]
  def change
    add_column :cuentas_bancarias, :has_chequera, :boolean, default: false, if_not_exists: true
  end
end
