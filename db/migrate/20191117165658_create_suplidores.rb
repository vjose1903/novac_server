class CreateSuplidores < ActiveRecord::Migration[5.2]
  def change
    create_table :suplidores do |t|
      t.string :nombre
      t.string :telefono
      t.string :direccion
      t.string :email

      t.timestamps
    end
  end
end
