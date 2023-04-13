class CreateTipoArticuloCuentasContables < ActiveRecord::Migration[7.0]
  def change
    create_table :tipo_articulo_cuentas_contables do | t |
      t.references :origen_tipo,                   null: false,  polymorphic: true
			t.references :configuracion_entidad_cuenta,  null: true,  foreign_key: true,                             index: { name: 'idx_tipo_art_config_ent_cuenta' }
      t.references :cuenta_contable_control,       null: false,  foreign_key: { to_table: :cuentas_contables }, index: { name: 'idx_tipo_art_cuenta_cont_cont' }
      t.references :cuenta_contable_auxiliar,      null: true,  foreign_key: { to_table: :cuentas_contables }, index: { name: 'idx_tipo_art_cuenta_cont_aux' }
      t.string     :key

      t.timestamps
    end
  end
end
