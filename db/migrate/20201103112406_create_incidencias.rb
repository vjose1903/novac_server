class CreateIncidencias < ActiveRecord::Migration[5.2]
  def change
    create_table :incidencias do |t|
      t.integer :referencia
      t.string :descripcion

      t.timestamps
    end
  end
end
