class CreateMovimientosInventarios < ActiveRecord::Migration[5.2]
  def change
    create_table :movimientos_inventarios do |t|
      t.references :user, foreign_key: true
      t.references :articulo, foreign_key: true
      t.float :cantidad
      t.string :accion
      t.string :motivo
      t.string :medida
      t.timestamps
    end
  end
end
