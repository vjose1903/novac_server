class CreateCategoriasEntidadesContables < ActiveRecord::Migration[7.0]
  def change
    create_table :categorias_entidades_contables do |t|
      t.references :cuenta_contable_control,       null: false,  foreign_key: { to_table: :cuentas_contables }, index: { name: 'idx_cat_ent_cont_cuenta_cont_cont' }
      t.references :cuenta_contable_auxiliar,      null: true,  foreign_key: { to_table: :cuentas_contables }, index: { name: 'idx_cat_ent_cont_cuenta_cont_aux' }
      t.references :configuracion_entidad_cuenta,  null: false,  foreign_key: true,                             index: { name: 'idx_cat_ent_cont_cuenta_cont_config_ent' }
      t.string     :descripcion
      t.string     :key
      t.string     :entidad

      t.timestamps
    end
  end
end
