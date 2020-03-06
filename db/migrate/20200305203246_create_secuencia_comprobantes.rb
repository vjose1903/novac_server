class CreateSecuenciaComprobantes < ActiveRecord::Migration[5.2]
  def change
    create_table :secuencia_comprobantes do |t|
      t.references :tipo_factura, foreign_key: true
      t.integer :secuencia
      t.integer :desde
      t.integer :hasta
      t.timestamp :fecha_compra
      t.timestamp :fecha_valida
      t.boolean :estado

      t.timestamps
    end
  end
end
