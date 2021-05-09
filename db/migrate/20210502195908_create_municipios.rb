class CreateMunicipios < ActiveRecord::Migration[5.2]
  def change
    create_table :municipios do |t|
      t.references :provincia, foreign_key: true
      t.string :nombre

      t.timestamps
    end
  end
end
