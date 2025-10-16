class CreateCamionesViajes < ActiveRecord::Migration[6.1]
  def change
    create_table :camiones_viajes do |t|
      t.references :vehiculo, null: false, foreign_key: true
      t.references :cabecera_factura, null: false, foreign_key: true

      t.timestamps
    end
  end
end
