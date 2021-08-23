class AddCamposToDocumentosDeIdentidad < ActiveRecord::Migration[5.2]
  def change
    add_reference :documentos_de_identidad, :origen, polymorphic: true, index: true
    add_index :documentos_de_identidad, [:documento, :origen_type], unique: true
  end
end
