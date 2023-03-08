class CreateCuentasContables < ActiveRecord::Migration[7.0]
  def change
    create_table :cuentas_contables do |t|
      t.references :grupo_cuenta, null: false, foreign_key: true
      t.string :descripcion
      t.integer :cuenta_control
      t.string :codigo
      t.integer :nivel
      t.string :origen
      t.string :tipo
			t.boolean :is_control
			t.boolean :estado, :default => true

      t.timestamps
    end
  end
end
