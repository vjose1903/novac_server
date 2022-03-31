class CreateOtrosCostosMantenimientosArticulos < ActiveRecord::Migration[6.1]
  def change
    create_table :otros_costos_mantenimientos_articulos do |t|
      t.references :otro_costo_historial, null: false, foreign_key: true, index: { name: 'index_otros_costos_mantenimientos_on_otro_costo_historial_id'}
      t.references :mantenimiento_articulo, null: false, foreign_key: true, index: { name: 'index_otros_costos_mantenimientos_on_mantenimiento_art'}

      t.timestamps
    end
  end
end