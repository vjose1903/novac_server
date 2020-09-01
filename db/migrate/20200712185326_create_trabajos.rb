class CreateTrabajos < ActiveRecord::Migration[5.2]
  def change
    create_table :trabajos do |t|
      t.references :cliente, foreign_key: true
      t.string :tipo_trabajo
      t.references :marca, foreign_key: true
      t.references :modelo, foreign_key: true
      t.string :identificador
      t.boolean :tiene_bateria
      t.string :descripcion
      t.string :notas
      t.boolean :empezado
      t.boolean :terminado
      t.boolean :estado
      t.boolean :entregado
      t.datetime :fecha_cancelado
      t.datetime :fecha_reactivado

      t.timestamps
    end
  end
end
