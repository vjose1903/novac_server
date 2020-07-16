class DocumentoDeIdentidad < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :suplidor, optional: true
  belongs_to :cliente, optional: true

  validates :documento, uniqueness: { case_sensitive: false, :message => "ya esta registrado" }, :allow_blank => true, :allow_nil => true

  def self.get_documentos_by_user_id(id)
    return ActiveRecord::Base.connection.exec_query("SELECT id, user_id, descripcion, documento, principal, created_at, updated_at, cliente_id, suplidor_id FROM documentos_de_identidad WHERE user_id = #{id}")
  end
  def self.get_documentos_by_cliente_id(id)
    return ActiveRecord::Base.connection.exec_query("SELECT id, user_id, descripcion, documento, principal, created_at, updated_at, cliente_id, suplidor_id FROM documentos_de_identidad WHERE cliente_id = #{id}")
  end
  def self.get_documentos_by_suplidor_id(id)
    return ActiveRecord::Base.connection.exec_query("SELECT id, user_id, descripcion, documento, principal, created_at, updated_at, cliente_id, suplidor_id FROM documentos_de_identidad WHERE suplidor_id = #{id}")
  end
end
