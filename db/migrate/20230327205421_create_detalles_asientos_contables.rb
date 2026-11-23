class CreateDetallesAsientosContables < ActiveRecord::Migration[7.0]
  def change
    create_table :detalles_asientos_contables do |t|
      t.references :cabeza_asiento_contable,  null: false,   foreign_key: true,                             index: { name: 'idx_det_as_cont_cabeza_asi_cont' }
      t.references :cuenta_contable_auxiliar, null: false,   foreign_key: { to_table: :cuentas_contables }, index: { name: 'idx_det_as_cont_cuenta_cont_aux' }
      t.references :cuenta_contable_control,  null: false,   foreign_key: { to_table: :cuentas_contables }, index: { name: 'idx_det_as_cont_cuenta_cont_cont' }
      t.float      :valor_debito
      t.float      :valor_credito

      t.timestamps
    end
  end
end
