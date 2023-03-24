class CreateCuentasContablesCuentasBancarias < ActiveRecord::Migration[7.0]
  def change
    create_table :cuentas_contables_cuentas_bancarias do |t|
      t.references :cuenta_bancaria, null: false, foreign_key: true
      t.references :cuenta_contable, null: false, foreign_key: true
      t.boolean :is_prima

      t.timestamps
    end
  end
end
