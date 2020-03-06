class CreateSecuenciaFacturas < ActiveRecord::Migration[5.2]
  def change
    create_table :secuencia_facturas do |t|
      t.references :tipo_factura, foreign_key: true
      t.integer :secuencia
      
      t.timestamps
    end
  end
end
