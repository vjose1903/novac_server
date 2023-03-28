class CreateSubTipoArticulos < ActiveRecord::Migration[7.0]
  def change
    create_table :sub_tipo_articulos do |t|
      t.references :tipo_articulo,              null: false,  foreign_key: true
      t.references :cuenta_contable_control,    null: false,  foreign_key: { to_table: :cuentas_contables }
      t.references :cuenta_contable_auxiliar,   null: false,  foreign_key: { to_table: :cuentas_contables }
      t.string     :descripcion

      t.timestamps
    end
  end
end
