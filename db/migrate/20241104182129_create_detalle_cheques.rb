class CreateDetalleCheques < ActiveRecord::Migration[7.0]
  def change
    create_table :detalle_cheques do |t|
      t.references  :cheque, null: false, foreign_key: true
      t.string      :comentario
      t.float       :tasa
      t.float       :monto
      t.float       :monto_local

      t.timestamps
    end
  end
end
