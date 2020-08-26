class CreateDocumentosDeIdentidad < ActiveRecord::Migration[5.2]
  def change
    create_table :documentos_de_identidad do |t|
      t.references :user, foreign_key: true
      t.references :cliente, foreign_key: true
      t.references :suplidor, foreign_key: true
      t.string :descripcion
      t.string :documento
      t.boolean :principal

      t.timestamps
    end
  end
end
