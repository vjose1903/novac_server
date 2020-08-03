class DocumentoDeIdentidad < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :cliente, optional: true
  belongs_to :suplidor, optional: true

  validates :documento, uniqueness: { case_sensitive: false, :message => "Documento de identidad ya esta registrado" }

  def self.get_documentos_by_user_id(id)
    return my_query("SELECT id, user_id, descripcion, documento, principal, created_at, updated_at, cliente_id, suplidor_id FROM documentos_de_identidad WHERE user_id = #{id}")
  end
  def self.get_documentos_by_cliente_id(id)
    return my_query("SELECT id, user_id, descripcion, documento, principal, created_at, updated_at, cliente_id, suplidor_id FROM documentos_de_identidad WHERE cliente_id = #{id}")
  end
  def self.get_documentos_by_suplidor_id(id)
    return my_query("SELECT id, user_id, descripcion, documento, principal, created_at, updated_at, cliente_id, suplidor_id FROM documentos_de_identidad WHERE suplidor_id = #{id}")
  end
end
