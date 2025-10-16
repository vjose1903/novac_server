class CreateVehiculos < ActiveRecord::Migration[5.2]
  def change
    create_table :vehiculos do |t|
      t.references :user, foreign_key: true
      t.string :marca
      t.string :modelo
      t.integer :cantidad_viajes

      t.timestamps
    end
  end
end
