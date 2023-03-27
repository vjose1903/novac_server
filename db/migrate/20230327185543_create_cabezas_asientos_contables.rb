class CreateCabezasAsientosContables < ActiveRecord::Migration[7.0]
  def change
    create_table :cabezas_asientos_contables do |t|
      t.references :usuario_creador,      null: false,  foreign_key: { to_table: :users }
      t.references :usuario_anulador,     null: true,   foreign_key: { to_table: :users }
      t.references :periodo_fiscal,       null: false,  foreign_key: true
      t.string     :comentario
      t.string     :tipo
      t.date       :fecha_equivalente
      t.date       :fecha_anulacion
      t.boolean    :estado,               default: true

      t.timestamps
    end
  end
end
