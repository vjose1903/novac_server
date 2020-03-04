class CreateMantenimientoArticulos < ActiveRecord::Migration[5.2]
  def change
    create_table :mantenimiento_articulos do |t|
      t.references :articulo, foreign_key: true
      t.references :user, foreign_key: true
      t.string :ant_nombre
      t.string :ant_tipoArticulo
      t.integer :ant_suplidor
      t.string :ant_medida
      t.float :ant_costoP
      t.float :ant_precioP
      t.integer :ant_alertaExistencia
      t.boolean :ant_isDetallable

      t.timestamps
    end
  end
end
