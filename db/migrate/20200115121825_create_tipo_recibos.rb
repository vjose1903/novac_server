class CreateTipoRecibos < ActiveRecord::Migration[5.2]
  def change
    create_table :tipo_recibos do |t|
      t.text :descripcion
      t.timestamps
    end
  end
end
