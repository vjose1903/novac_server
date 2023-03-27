class CreateCuentasBancarias < ActiveRecord::Migration[7.0]
  def change
    create_table :cuentas_bancarias do | t |
      t.references :banco,                     null: false,  foreign_key: true
      t.references :tipo_cuenta_bancaria,      null: false,  foreign_key: true
      t.references :divisa,                    null: false,  foreign_key: true
      t.references :cuenta_contable,           null: false,  foreign_key: true
      t.references :cuenta_contable_prima,     null: true,   foreign_key: { to_table: :cuentas_contables }
      t.date       :fecha_apertura
      t.string     :numero_cuenta
      t.string     :comentario
      t.string     :descripcion
      t.boolean    :is_nacional
      t.boolean    :estado,      :default =>  true

      t.timestamps
    end
  end
end



