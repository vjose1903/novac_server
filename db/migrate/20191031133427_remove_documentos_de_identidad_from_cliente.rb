class RemoveDocumentosDeIdentidadFromCliente < ActiveRecord::Migration[5.2]
  def change
    remove_column :clientes, :documento_de_identidad_id, :reference
  end
end
