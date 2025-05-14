class CreateCommertialApprovalReceptions < ActiveRecord::Migration[7.0]
  def change
    create_table :commertial_approval_receptions do |t|
      t.references :cabecera_factura, null: true, foreign_key: true
      t.string     :eNCF
      t.string     :rnc_emisor
      t.string     :rnc_comprador
      t.float      :monto_total
      t.integer    :estado
      t.string     :fecha_emision
      t.string     :detalleMotivoRechazo
      t.string     :xml_file_name

      t.timestamps
    end
  end
end
