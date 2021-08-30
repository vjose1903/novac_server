# frozen_string_literal: true

class User < ApplicationRecord
  extend Devise::Models
  belongs_to :imagen, optional: true
  accepts_nested_attributes_for :imagen

  has_many :documentos_de_identidad, :as => :origen, dependent: :destroy, class_name: "DocumentoDeIdentidad"
  accepts_nested_attributes_for :documentos_de_identidad


  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :timeoutable
  
  validates :usuario, presence: { :message => "Usuario no puede estar vacio." }, uniqueness: { case_sensitive: false, :message => "El nombre de usuario ya esta registrado" }
  validates :telefono, presence: { :message => "Telefono no puede estar vacio." }
  validates :email, presence: { :message => "Email no puede estar vacio." }, uniqueness: { case_sensitive: false, :message => "ya esta registrado" }

  include DeviseTokenAuth::Concerns::User

  def self.get_vendedor_by_id(id)
    return my_query("SELECT * FROM users WHERE estado = #{true} AND role = 'V' AND id = #{id}")
  end

  # ============================================================================================
  # HANDLE FILTER
  # ============================================================================================
  def self.handleFilter(parametros)
    filter_key = parametros["filter_key"]
    filter_value = parametros["filter_value"]

    if filter_key == 'role'
      return User.all.where("lower(role) like lower('%#{filter_value}%') and estado = true")
    else
      return User.all.where("#{filter_key} = #{filter_value} and estado = true")
    end

  end  
  # =====================================================================================================================

  def self.crear_actualizar_user(params , is_save=false)
    User.transaction do
      res = Response.new
      
      unless params["id"]
        user = User.new()
      else
        user = User.find_by_id(params["id"])
      end

      user.nombre                 = params["nombre"]
      user.apellido               = params["apellido"]
      user.usuario                = params["usuario"]
      user.sexo                   = params["sexo"]
      user.telefono               = params["telefono"]
      user.email                  = params["email"]
      user.fecha_nacimiento       = params["fecha_nacimiento"]
      user.role                   = params["role"]
      user.password               = params["password"] if params["password"]
      user.password_confirmation  = params["password"] if params["password"]
      user.estado                 = true

      puts "user ==>  ".blue  + "#{user.to_json}"
      puts "user.valid ==>  ".green  + "#{user.valid?}"

      puts "user.errors ==>  ".cyan  + "#{user.errors.to_json}"

      
      if user.errors.to_a.empty? && user.valid?
        dependencias = [{modelo: DocumentoDeIdentidad, key_object: "documentos_de_identidad", padre: user}]

        res = crear_actualizar_dependencias(dependencias, params, true) { |key_object, dependencia_data| 
          user.documentos_de_identidad = dependencia_data if key_object == 'documentos_de_identidad'
        }
        
        if res.status_valid && user.save!
          res.set_data(serialize_parser(user,{}))

          action = params["id"] ? 'actualizado' : 'creado'
          res.add_msg("Empleado #{action} correctamente.")
        end
      end
      
      puts "user ==>  ".red  + "#{user.to_json}"
      puts "user.errors.to_a ==>  ".red  + "#{user.errors.to_a}"
      unless user.errors.to_a.empty?
        
        res.add_msgs(user.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
        return res
        raise ActiveRecord::Rollback
      end

      return res
    end
  end

  # =====================================================================================================================

  def self.filtrarUsusarios(arg, params)
    res = Response.new

    users = User
    .joins("left join documentos_de_identidad on users.id = documentos_de_identidad.origen_id AND documentos_de_identidad.origen_type = 'User' AND documentos_de_identidad.principal = true")
    .where("lower(users.nombre || ' ' || coalesce(users.email, '') || ' ' || coalesce(documentos_de_identidad.documento, '')) like lower('%#{arg}%')  AND users.estado = true AND sexo != 'i'")
    .order("users.id ASC").to_a

    if users.length > 0
      puts "users.length > 0 ".yellow 
      puts "users: ".yellow  + "#{users.to_json}"
      res.set_data(users, {all: true}, params)
    else
      res.set_data([])
      res.add_msg("No existe empleado con las especificaciones introducidas")
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

    # =========================================================================================================================================================

    def self.mudar_info(param)
      res = {"correcto" => true}
      DocumentoDeIdentidad.all.each do |documento|

        if !documento.user.nil?
          documento.origen = documento.user

        elsif !documento.suplidor.nil?
          documento.origen = documento.suplidor

        elsif !documento.cliente.nil?
          documento.origen = documento.cliente
          
        end

        documento.save!
        
      end
      return res
    end

end
