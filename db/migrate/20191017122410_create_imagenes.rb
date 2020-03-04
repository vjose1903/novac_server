class CreateImagenes < ActiveRecord::Migration[5.2]
  def change
    create_table :imagenes do |t|
      t.string :fileName
      t.string :base_64
      t.string :path

      t.timestamps
    end
  end
end
