class CreateCostoFletes < ActiveRecord::Migration[5.2]
  def change
    create_table :costo_fletes do |t|
      t.references :municipio, foreign_key: true, null: false
      t.float :costo, default: 0
      t.boolean :estado, default: true
      
      t.timestamps
    end
  end
end
