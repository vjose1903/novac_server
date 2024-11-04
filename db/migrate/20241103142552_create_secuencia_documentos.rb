class CreateSecuenciaDocumentos < ActiveRecord::Migration[7.0]
  def change
    create_table :secuencia_documentos do |t|
      t.references :origen_secuencia, polymorphic: true, null: false
      t.integer    :secuencia,        default: 1

      t.timestamps
    end
  end
end
