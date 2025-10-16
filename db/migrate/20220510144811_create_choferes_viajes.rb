class CreateChoferesViajes < ActiveRecord::Migration[6.1]
  def change
    create_table :choferes_viajes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :recibos_ingreso, null: false, foreign_key: true

      t.timestamps
    end
  end
end
