# frozen_string_literal: true

class User < ApplicationRecord
  rolify
  extend Devise::Models
  belongs_to :imagen, optional: true
  accepts_nested_attributes_for :imagen

  has_many :documentos_de_identidad, :as => :origen, dependent: :destroy, class_name: "DocumentoDeIdentidad"
  accepts_nested_attributes_for :documentos_de_identidad

  # has_many :users_roles, dependent: :destroy
  # has_and_belongs_to_many :roles, join_table: :users_roles

  has_many :roles_permisos_acciones, through: :roles

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :timeoutable

  validates :usuario,             presence: { :message => "Usuario no puede estar vacio." },                  uniqueness: { case_sensitive: false, :message => "El nombre de usuario ya esta registrado" }
  validates :telefono,            presence: { :message => "Telefono no puede estar vacio." }
  validates :email,               presence: { :message => "Email no puede estar vacio." },                    uniqueness: { case_sensitive: false, :message => "El email introducido ya esta registrado" }
  validates :nombre,              presence: { :message => "Nombre del empleado no puede estar vacio." },      uniqueness: { scope: :estado, case_sensitive: false, :message => "Empleado ya esta registrado" }, :if => :estado
  validates :apellido,            presence: { :message => "Apellido del empleado no puede estar vacio." }
  validates :sexo,                presence: { :message => "Sexo del empleado no puede estar vacio." }
  validates :fecha_nacimiento,    presence: { :message => "Fecha de nacimiento del empleado no puede estar vacia." }

  before_validation :otras_validaciones
  include DeviseTokenAuth::Concerns::User

  def otras_validaciones
  end

  def self.models_includes
    includes = [:documentos_de_identidad, {roles_permisos_acciones: [:role, :permiso_accion]}]
    return includes
  end

  def self.models_includes_for(params)
    includes = []
    includes << :documentos_de_identidad if params[:all] || params[:documentos_de_identidad]
    includes << :roles if params[:roles]
    includes << {roles_permisos_acciones: [:role, :permiso_accion]} if params[:permisos]
    includes
  end

  def nombre_completo
    nombre    = self.nombre.capitalize
    nombre    += " #{self.apellido.capitalize}" unless self.apellido.blank?
    nombre    = nombre.gsub("  ", " ").strip
    nombre
  end

  def self.get_vendedor_by_id(id)
    return my_query("SELECT * FROM users WHERE estado = #{true} AND role = 'V' AND id = #{id}")
  end

  # ============================================================================================
  # HANDLE FILTER
  # ============================================================================================
  def self.handleFilter(parametros)

    if parametros["filter_key"] == 'role'
			return User.joins(:roles).where(roles: {key: parametros["filter_value"]})
    elsif parametros["filter_key"] == 'cedula'

      return User.joins(:documentos_de_identidad).where(documentos_de_identidad: {descripcion: Documentos.cedula , documento: parametros["filter_value"]}).where("usuario NOT IN ('novac', 'adm01')")
    elsif parametros["filter_key"] == 'rnc'
      return User.joins(:documentos_de_identidad).where(documentos_de_identidad: {descripcion: Documentos.rnc , documento: parametros["filter_value"]}).where("usuario NOT IN ('novac', 'adm01')")
    else
      return User.all.where("#{parametros["filter_key"]} = #{parametros["filter_value"]} and estado = true")
    end

  end

  def self.serialized_response(users, params, serializer_params, msg=nil)
    paginate_class = Paginator.new(params)
    includes = User.models_includes_for(serializer_params)
    paginate_class.paginate_data(users, includes.empty? ? nil : includes)

    res = {status: HTTP_STATUS_CODE[:ok], data: UserSerializer.collection_to_hash(paginate_class.get_data, serializer_params), msg: msg}
    if paginate_class.is_paginated
      res[:total_registros] = paginate_class.get_total_registros
      res[:total_paginas] = paginate_class.get_total_paginas
    end
    res
  end
  # =====================================================================================================================

  def checkRoles(params)
      self.errors.add(:base, "Debe de especificar almenos un role al empleado.") if !params[:ids_roles].present? || params[:ids_roles].length == 0
  end

  # =====================================================================================================================

  def self.crear_actualizar_user(params , is_save=false)
    res                           = Response.new
    User.transaction do
      user                        = User.where(:id => params["id"]).first_or_initialize

      user.nombre                 = params["nombre"]
      user.apellido               = params["apellido"]
      user.usuario                = params["usuario"]
      user.sexo                   = params["sexo"]
      user.telefono               = params["telefono"]
      user.email                  = params["email"]
      user.fecha_nacimiento       = Date.parse params["fecha_nacimiento"]
      user.password               = params["password"] if params["password"]
      user.password_confirmation  = params["password"] if params["password"]
      user.estado                 = true
      user.roles                  = Role.where(id: params["ids_roles"])

      user.valid?
      user.checkRoles(params)

      if user.errors.empty?
        dependencias = [{modelo: DocumentoDeIdentidad, key_object: "documentos_de_identidad", padre: user}]

        res = crear_actualizar_dependencias(dependencias, params, true) { |key_object, dependencia_data|
          user.documentos_de_identidad = dependencia_data if key_object == 'documentos_de_identidad'
        }

        if res.status_valid && user.save!
          res.set_data(serialize_parser(user, {all: true}))

          action = params["id"] ? 'actualizado' : 'creado'
          res.add_msg("Empleado #{action} correctamente.")
        end
      end

      unless user.errors.empty?
        res.add_msgs(user.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      raise ActiveRecord::Rollback if !user.errors.empty? || !res.status_valid
    end

    return res
  end

  # =====================================================================================================================
  def self.filtrarUsusarios(arg, params)
    arg = ActiveRecord::Base.sanitize_sql_like(arg.to_s.strip)
    serializer_params = {all: true, roles: true}
    users = User
    .joins("left join documentos_de_identidad on users.id = documentos_de_identidad.origen_id AND documentos_de_identidad.origen_type = 'User' AND documentos_de_identidad.principal = true")
    .where("LOWER(COALESCE(users.nombre, '') || ' ' || COALESCE(users.apellido, '') || ' ' || COALESCE(users.email, '') || ' ' || COALESCE(documentos_de_identidad.documento, '')) LIKE LOWER(?) AND users.estado = true AND sexo != 'i'", "%#{arg}%")
    .order("users.id ASC")

    return Response.new(params, HTTP_STATUS_CODE[:ok], users, [], serializer_params, User.models_includes_for(serializer_params)) if users.exists?

    res = Response.new(params)
    res.set_data([])
    cantidad_registros = User.where({estado: true}).count
    res.add_msg(cantidad_registros == 0 ? "No existen empleados registrados." : "No existe empleado con las especificaciones introducidas")
    res.set_status(HTTP_STATUS_CODE[:conflict])
    res
  end

    # =========================================================================================================================================================
    def get_permisos

      joins_ = "INNER JOIN permisos_acciones on permisos_acciones.id = roles_permisos_acciones.permiso_accion_id"
      joins_ += " INNER JOIN acciones on acciones.id = permisos_acciones.accion_id"
      joins_ += " INNER JOIN permisos on permisos.id = permisos_acciones.permiso_id"

      roles_permisos_acciones                    = self.roles_permisos_acciones.joins(joins_).select("roles_permisos_acciones.permiso_accion_id, CONCAT(permisos.descripcion, '_', acciones.descripcion) as permiso").group("roles_permisos_acciones.permiso_accion_id, permisos.descripcion, acciones.descripcion")

      roles_permisos_acciones
    end
    # =========================================================================================================================================================
    def  verificateHasPermiso(permiso_descripcion)
      return Permiso.verificateUserPermiso(self.id, permiso_descripcion)
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
