class CreateConfiguracionesEntidadesCuentas < ActiveRecord::Migration[7.0]
  def change
    create_table :configuraciones_entidades_cuentas do |t|
      t.string :descripcion
      t.references :cuenta_contable, null: false, foreign_key: true

      t.timestamps
    end
  end
end
