class CreateSubTipoArticulos < ActiveRecord::Migration[7.0]
  def change
    create_table :sub_tipo_articulos do |t|
      t.references :tipo_articulo,              null: false,  foreign_key: true
      t.string     :descripcion

      t.timestamps
    end
  end
end
