class CreateTransferencias < ActiveRecord::Migration[7.0]
  def change
    create_table :transferencias do |t|
      t.references :cuenta_bancaria_origen,       null: false,  foreign_key: { to_table: :cuentas_bancarias }
      t.references :cuenta_bancaria_destino,      null: true,   foreign_key: { to_table: :cuentas_bancarias }
      t.references :divisa,                       null: false,  foreign_key: true
      t.references :user_creador,                 null: false,  foreign_key: { to_table: :users }
      t.references :last_user_update,             null: true,   foreign_key: { to_table: :users }
      t.references :user_anulador,                null: true,   foreign_key: { to_table: :users }
      t.float      :tasa
      t.float      :monto
      t.float      :monto_local
      t.string     :comentario
      t.string     :nombre_banco_tercero,         null: true
      t.string     :cuenta_bancaria_tercero,      null: true
      t.string     :numero_referencia
      t.date       :fecha_equivalente
      t.date       :fecha_anulacion
      t.boolean    :estado, default: true

      t.timestamps
    end
  end
end
