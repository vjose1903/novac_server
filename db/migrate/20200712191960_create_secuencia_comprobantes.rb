class CreateSecuenciaComprobantes < ActiveRecord::Migration[5.2]
  def change
    create_table :secuencia_comprobantes do |t|
      t.references :tipo_factura, foreign_key: true
      t.integer :secuencia
      t.integer :desde
      t.integer :hasta
      t.datetime :fecha_compra
      t.datetime :fecha_valida
      t.boolean :estado
      t.boolean :usado

      t.timestamps
    end
  end
end
