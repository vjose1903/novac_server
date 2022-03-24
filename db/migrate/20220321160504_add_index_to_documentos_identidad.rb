class AddIndexToDocumentosIdentidad < ActiveRecord::Migration[6.1]
  def change
		remove_index :documentos_de_identidad, name: "index_documentos_de_identidad_on_documento_and_origen_type"
  end
end
