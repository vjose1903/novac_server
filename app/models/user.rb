# frozen_string_literal: true

class User < ApplicationRecord
  extend Devise::Models
  belongs_to :imagen, optional: true

  has_many :documentos_de_identidad, dependent: :destroy
  attribute :documentos_de_identidad

  accepts_nested_attributes_for :imagen
  accepts_nested_attributes_for :documentos_de_identidad

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :timeoutable
  
  validates :usuario, presence: { :message => "Usuario no puede estar vacio." }, uniqueness: { case_sensitive: false, :message => "ya esta registrado" }
  validates :telefono, presence: { :message => "Telefono no puede estar vacio." }, uniqueness: { case_sensitive: false, :message => "ya esta registrado" }
  validates :email, presence: { :message => "Email no puede estar vacio." }, uniqueness: { case_sensitive: false, :message => "ya esta registrado" }
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
  # =====================================================================================================================

  def self.filtrarUsusarios(arg)
    arg = arg === " " ? "" : arg

    select_ = "SELECT u.id, u.uid, u.sign_in_count, u.nombre, u.usuario, u.apellido, u.sexo, u.telefono, u.email, u.fecha_nacimiento, u.role, u.created_at, u.updated_at, u.estado"
    from_ = "FROM users u "
    where_ = "where lower(u.nombre || ' ' || u.apellido ) like lower('%#{arg}%') AND estado = true AND sexo != 'i'"
    order_ = "ORDER BY u.id ASC"

    query = "#{select_} #{from_} #{where_} #{order_}"

    my_query(query)
  end

  # =====================================================================================================================

  def self.parsearUsuariosFiltro(usuarios)
    usuarios.each do |user|
      user["nombre"] = user["nombre"].capitalize
      user["apellido"] = user["apellido"].capitalize
    end

    return usuarios
  end

    # =========================================================================================================================================================

    def self.mudar_info(param)
    res = {"correcto" => true}
    User.all.each do |user|
      documentos = DocumentoDeIdentidad.where({ user_id: user["id"] })
    
      documentos.each do |doc|
        user['cedula']  = doc["documento"]  if doc["descripcion"].downcase == "cedula"
      end
      user['principal'] = "cedula"
      # user['cedula'] =nil 

      unless user.save!
        res = {"correcto" => false}
        break
      end
      
    end
    return res
  end

end
