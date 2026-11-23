class CreateEntidadCuentasContables < ActiveRecord::Migration[7.0]
  def change
    create_table :entidad_cuentas_contables do |t|
      t.references :origen_entidad,                polymorphic: true,  null: false, index: true
      t.string     :key
      t.string     :tipo_agrupacion_contable
      t.references :cuenta_contable,               foreign_key: true,  null: true
      t.references :origen_categoria,              polymorphic: true,  null: true
      t.references :configuracion_entidad_cuenta,  foreign_key: true,  null: false, index: { name: 'idx_ent_cuenta_cont_config_ent' }
      t.boolean    :is_comun, default: false
      t.timestamps
    end
  end
end
