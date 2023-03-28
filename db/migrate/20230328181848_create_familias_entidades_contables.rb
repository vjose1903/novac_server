class CreateFamiliasEntidadesContables < ActiveRecord::Migration[7.0]
  def change
    create_table :familias_entidades_contables do |t|
      t.string :descripcion
      t.string :entidad
			t.references :cuenta_contable_control,   null: false,  foreign_key: { to_table: :cuentas_contables }
			t.references :cuenta_contable_auxiliar,  null: false,  foreign_key: { to_table: :cuentas_contables }

      t.timestamps
    end
  end
end
