class CreateTasasDeCambio < ActiveRecord::Migration[7.0]
  def change
    create_table :tasas_de_cambio do |t|

      t.references :divisa, null: false, foreign_key: true
      t.date       :fecha_equivalente
      t.float      :valor,               :default => 0
      t.integer    :secuencia,           :default => 0

      t.timestamps

    end
  end
end
