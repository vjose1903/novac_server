class AddClienteToDocumentosDeIdentidad < ActiveRecord::Migration[5.2]
  def change
    add_reference :documentos_de_identidad, :cliente, foreign_key: true
  end
end
