class CreateCuadreCajaEventos < ActiveRecord::Migration[7.0]
  def change
    create_table :cuadre_caja_eventos do |t|
      t.references :cuadre_caja, null: false, foreign_key: true
      t.references :user, foreign_key: true
      t.string :event_type, null: false
      t.string :from_status
      t.string :to_status
      t.text :reason
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :cuadre_caja_eventos, [:cuadre_caja_id, :created_at], name: 'idx_cuadre_eventos_fecha'
  end
end
