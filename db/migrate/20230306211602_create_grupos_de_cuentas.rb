class CreateGruposDeCuentas < ActiveRecord::Migration[7.0]
  def change
    create_table :grupos_de_cuentas do |t|
      t.string :descripcion
      t.integer :grupo
      t.string :origen
      t.string :tipo
      t.boolean :estado, :default => true

      t.timestamps
    end
  end
end
