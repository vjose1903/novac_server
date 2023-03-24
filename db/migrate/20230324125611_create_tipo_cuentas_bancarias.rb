class CreateTipoCuentasBancarias < ActiveRecord::Migration[7.0]
  def change
    create_table :tipo_cuentas_bancarias do |t|
      t.string :descripcion
      t.boolean :estado,   :default => true

      t.timestamps
    end
  end
end
