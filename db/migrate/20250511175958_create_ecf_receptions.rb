class CreateEcfReceptions < ActiveRecord::Migration[7.0]
  def change
    create_table :ecf_receptions do |t|
      t.references :suplidor, null: true, foreign_key: true
      t.string     :eNCF
      t.string     :rnc_emisor
      t.string     :rnc_comprador
      t.float      :monto_total
      t.boolean    :approved
      t.string     :fecha_emision

      t.timestamps
    end
  end
end
