class CreateTipoArticulos < ActiveRecord::Migration[5.2]
  def change
    create_table :tipo_articulos do |t|
      t.string :descripcion

      t.timestamps
    end
  end
end
