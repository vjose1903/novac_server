# frozen_string_literal: true

class User < ApplicationRecord
  extend Devise::Models

  has_one :documento_de_identidad, dependent: :destroy
  attribute :documento_de_identidad
  accepts_nested_attributes_for :documento_de_identidad, :allow_destroy => true

  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  validates :usuario, presence: { :message => "no puede estar vacio." }, uniqueness: { case_sensitive: false, :message => "ya esta registrado" }
  validates :telefono, presence: { :message => "no puede estar vacio." }, uniqueness: { case_sensitive: false, :message => "ya esta registrado" }
  validates :email, presence: { :message => "no puede estar vacio." }, uniqueness: { case_sensitive: false, :message => "ya esta registrado" }
  include DeviseTokenAuth::Concerns::User

  def self.get_users
    return my_query("SELECT * FROM users WHERE estado = #{true}")
  end

  def self.get_vendedores
    return my_query("SELECT * FROM users WHERE estado = #{true} AND role = 'V'")
  end

  def self.get_vendedor_by_id(id)
    return my_query("SELECT * FROM users WHERE estado = #{true} AND role = 'V' AND id = #{id}")
  end

  def self.get_user_by_id(id)
    return my_query("SELECT * FROM users WHERE id = #{id}")
  end

  def self.filtrarUsusarios(arg)
    arg = arg === " " ? "" : arg
    select_ = "SELECT u.id, u.uid, u.sign_in_count, u.nombre, u.usuario, u.apellido, u.sexo, u.telefono, u.email, u.fecha_nacimiento, u.role, u.created_at, u.updated_at, u.estado, doc.descripcion as doc_descripcion, doc.id as doc_id, doc.documento as doc_documento"
    from_ = "FROM users u "
    joins_ = "left join documentos_de_identidad doc on u.id = doc.cliente_id "
    where_ = "where lower(u.nombre || ' ' || u.apellido || ' ' || coalesce(doc.documento, '') ) like lower('%#{arg}%')"

    query = "#{select_} #{from_} #{joins_} #{where_}"

    my_query(query)
  end

  # =====================================================================================================================

  def self.parsearUsuariosFiltro(usuarios)
    usuarios.each do |user|
      if user["doc_id"]
        user["documento_de_identidad"] = { id: user["doc_id"], descripcion: user["doc_descripcion"], documento: user["doc_documento"], user_id: user["id"] }
      else
        user["documento_de_identidad"] = {}
      end
      user.delete("doc_descripcion")
      user.delete("doc_id")
      user.delete("doc_documento")
    end

    return usuarios
  end
end
