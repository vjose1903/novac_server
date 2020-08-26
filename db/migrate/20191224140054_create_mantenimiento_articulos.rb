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
      t.string :ant_medidaPadre
      t.float :ant_costoPadre
      t.float :ant_precioPadre
      t.integer :ant_cantidadPadre
      t.string :ant_medidaHijo
      t.float :ant_costoHijo
      t.float :ant_precioHijo
      t.integer :ant_cantidadHijo
      t.string :ant_medidaAlerta

      t.integer :ant_idPadre
      t.integer :ant_idHijo
      t.integer :ant_referenciaPadre
      t.integer :ant_referenciaHijo
      t.integer :ant_tipoArticuloId

      t.boolean :ant_isCombo
      t.boolean :ant_calcularItbis

      t.timestamps
    end
  end
end
