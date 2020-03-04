class CreateSecuenciaIngresos < ActiveRecord::Migration[5.2]
  def change
    create_table :secuencia_ingresos do |t|
      t.references :tipo_recibo, foreign_key: true
      t.integer :secuencia
      t.timestamps
    end
  end
end
