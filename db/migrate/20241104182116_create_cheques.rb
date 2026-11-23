class CreateCheques < ActiveRecord::Migration[7.0]
  def change
    create_table :cheques do |t|
      t.references  :cuenta_bancaria,      null: false, foreign_key: true
      t.references  :divisa,               null: false, foreign_key: true
      t.float       :tasa
      t.float       :monto
      t.float       :monto_local
      t.float       :balance
      t.string      :comentario
      t.datetime    :fecha_equivalente
      t.references  :user_creador,         null: false,  foreign_key: { to_table: :users }
      t.references  :last_user_update,     null: true,   foreign_key: { to_table: :users }
      t.date        :fecha_update
      t.references  :user_anulador,        null: true,   foreign_key: { to_table: :users }
      t.date        :fecha_anulacion
      t.integer     :secuencia
      t.string      :estado,               default: STATUS.active

      t.timestamps
    end
  end
end

