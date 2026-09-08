class CreateConfiguracionCuadres < ActiveRecord::Migration[7.0]
  def change
    create_table :configuracion_cuadres do |t|
      t.jsonb :config, default: {}, null: false

      t.timestamps
    end
  end
end
