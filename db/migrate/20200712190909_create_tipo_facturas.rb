class CreateTipoFacturas < ActiveRecord::Migration[5.2]
  def change
    create_table :tipo_facturas do |t|
      t.string :referencia
      t.string :descripcion

      t.timestamps
    end
  end
end
