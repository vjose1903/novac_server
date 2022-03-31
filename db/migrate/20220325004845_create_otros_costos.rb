class CreateOtrosCostos < ActiveRecord::Migration[6.1]
  def change
    create_table :otros_costos do |t|
      t.string :descripcion
      t.float :costo

      t.timestamps
    end
  end
end
