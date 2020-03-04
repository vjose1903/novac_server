# frozen_string_literal: true

class User < ApplicationRecord
  extend Devise::Models
  belongs_to :imagen, optional: true

  has_many :documentos_de_identidad, dependent: :destroy
  attribute :documentos_de_identidad

  accepts_nested_attributes_for :imagen
  accepts_nested_attributes_for :documentos_de_identidad

  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable
  validates :usuario, presence: { :message => "Usuario no puede estar vacio." }, uniqueness: { case_sensitive: false, :message => "Usuario ya esta registrado" }
  validates :telefono, presence: { :message => "Telefono no puede estar vacio." }, uniqueness: { case_sensitive: false, :message => "Telefono ya esta registrado" }
  validates :email, presence: { :message => "Email no puede estar vacio." }, uniqueness: { case_sensitive: false, :message => "Email ya esta registrado" }
  include DeviseTokenAuth::Concerns::User

  def self.get_users
    return ActiveRecord::Base.connection.exec_query("SELECT * FROM users WHERE estado = #{true}")
  end

  def self.get_vendedores
    return ActiveRecord::Base.connection.exec_query("SELECT * FROM users WHERE estado = #{true} AND role = 'V'")
  end

  def self.get_vendedor_by_id(id)
    return ActiveRecord::Base.connection.exec_query("SELECT * FROM users WHERE estado = #{true} AND role = 'V' AND id = #{id}")
  end

  def self.get_user_by_id(id)
    return ActiveRecord::Base.connection.exec_query("SELECT * FROM users WHERE id = #{id}")
  end
end
