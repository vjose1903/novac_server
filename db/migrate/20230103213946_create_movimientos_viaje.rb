class CreateMovimientosViaje < ActiveRecord::Migration[7.0]
  def change
    create_table :movimientos_viaje do |t|
      t.references :user, null: true, foreign_key: true
      t.references :vehiculo, null: true, foreign_key: true
      t.references :cabecera_factura, null: false, foreign_key: true

      t.timestamps
    end
  end
end
