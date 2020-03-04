class AddSuplidorToDocumentosDeIdentidad < ActiveRecord::Migration[5.2]
  def change
    add_reference :documentos_de_identidad, :suplidor, foreign_key: true
  end
end
