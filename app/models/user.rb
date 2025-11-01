# frozen_string_literal: true

class User < ApplicationRecord
  rolify
  extend Devise::Models

  has_many  :imagenes,                  :as => :origen_img,       dependent: :destroy, class_name: 'Imagen'
  has_many  :entidad_cuentas_contables, :as => :origen_entidad,   dependent: :destroy, class_name: 'EntidadCuentaContable'
  has_many  :documentos_de_identidad,   :as => :origen,           dependent: :destroy, class_name: 'DocumentoDeIdentidad'
  has_many  :roles_permisos_acciones,   through: :roles

  devise   :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :timeoutable

  validates :usuario,             presence: { :message => 'Usuario no puede estar vacío.' },                  uniqueness: { case_sensitive: false, :message => 'El nombre de usuario ya está registrado' }
  validates :telefono,            presence: { :message => 'Telefono no puede estar vacío.' }
  validates :email,               presence: { :message => 'Email no puede estar vacío.' },                    uniqueness: { case_sensitive: false, :message => 'El email introducido ya está registrado' }
  validates :nombre,              presence: { :message => 'Nombre del empleado no puede estar vacío.' },      uniqueness: { scope: :estado, case_sensitive: false, :message => 'Empleado ya está registrado' }, :if => :estado
  validates :apellido,            presence: { :message => 'Apellido del empleado no puede estar vacío.' }
  validates :sexo,                presence: { :message => 'Sexo del empleado no puede estar vacío.' }
  validates :fecha_nacimiento,    presence: { :message => 'Fecha de nacimiento del empleado no puede estar vacia.' }

  include DeviseTokenAuth::Concerns::User

  def otras_validaciones(params, has_contabilidad)

    if has_contabilidad
      user_configs = ConfiguracionEntidadCuenta.where(:entidad => ConfigEntidadCuentaCont.user)
      if !params.has_key?(:cuentas_contables) || params[:cuentas_contables].nil? || ( user_configs.length < params[:cuentas_contables].length )
        self.errors.add(:base, 'Debe de especificar todas los atributos para cuentas contables.')
      end
    end

    self.errors.add(:base, 'Debe de especificar almenos un role al empleado.')                          if !params.has_key?(:ids_roles)         || params[:ids_roles].nil?
  end

  # =====================================================================================================================

  def self.models_includes
    includes = [
      :documentos_de_identidad,
      :imagenes,
      { entidad_cuentas_contables: [ :cuenta_contable, :configuracion_entidad_cuenta ] },
      { roles_permisos_acciones: [:role, :permiso_accion] }
    ]
    return includes
  end

  # =====================================================================================================================

  def nombre_completo
    nombre    = self.nombre.capitalize
    nombre    += " #{self.apellido.capitalize}" unless self.apellido.blank?
    nombre    = nombre.gsub('  ', ' ').strip
    nombre
  end
  # =====================================================================================================================

  # --------------------------------------------------------------------------------------------
  # HANDLE FILTER
  # --------------------------------------------------------------------------------------------
  def self.handleFilter(parametros)

    if parametros[:filter_key] == 'role'
      return User.joins(:roles).where(roles: {key: parametros[:filter_value]})
    elsif parametros[:filter_key] == 'cedula'

      return User.joins(:documentos_de_identidad).where(documentos_de_identidad: {descripcion: Documentos.cedula , documento: parametros[:filter_value]}).where("usuario NOT IN ('novac', 'adm01')")
    elsif parametros[:filter_key] == 'rnc'
      return User.joins(:documentos_de_identidad).where(documentos_de_identidad: {descripcion: Documentos.rnc , documento: parametros[:filter_value]}).where("usuario NOT IN ('novac', 'adm01')")
    else
      return User.all.where("#{parametros[:filter_key]} = #{parametros[:filter_value]} and estado = true")
    end

  end

  # =====================================================================================================================

  def self.crear_actualizar_user(params , is_save=false)
    res                           = Response.new
    @has_contabilidad             = system_has_contabilidad

    User.transaction do
      user                        = User.where(:id => params[:id]).first_or_initialize

      user.nombre                          = params[:nombre]
      user.apellido                        = params[:apellido]
      user.usuario                         = params[:usuario]
      user.sexo                            = params[:sexo]
      user.telefono                        = params[:telefono]
      user.email                           = params[:email]
      user.fecha_nacimiento                = Date.parse(params[:fecha_nacimiento])
      user.password                        = params[:password] if params[:password]
      user.password_confirmation           = params[:password] if params[:password]
      user.estado                          = true
      user.roles                           = Role.where(id: params[:ids_roles])

      user.valid?

      user.otras_validaciones(params, @has_contabilidad)

      if @has_contabilidad
        cuentas_config = { view_prima: false, tipo_categoria: CatContable.categoria_entidad_contable, descripcion_cuenta: user.nombre_completo }.with_indifferent_access
        EntCuentaContable.parsear_cuentas_contables(params, cuentas_config ) if user.errors.empty?
      end

      if user.errors.empty?
        dependencias = [ { modelo: DocumentoDeIdentidad,  key_object: 'documentos_de_identidad',   padre: user } ]
        dependencias.push({ modelo: EntidadCuentaContable, key_object: 'entidad_cuentas_contables', padre: user }) if @has_contabilidad


        res = crear_actualizar_dependencias(dependencias, params) { |key_object, dependencia_data|
          user.documentos_de_identidad    = dependencia_data if key_object == 'documentos_de_identidad'
          user.entidad_cuentas_contables  = dependencia_data if key_object == 'entidad_cuentas_contables'
        }

        if res.status_valid && user.save!
          res.set_data(serialize_parser(user, {all: true}))

          action = params[:id] ? 'actualizado' : 'creado'
          res.add_msg("Empleado #{action} correctamente.")
        end
      end

      unless user.errors.empty?
        res.add_msgs(user.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      transaction_rollback if !user.errors.empty? || !res.status_valid

    end

    return res
  end

  # =====================================================================================================================
  def self.filtrarUsusarios(arg, params)
    res = Response.new(params)
    users = User
    .joins("left join documentos_de_identidad on users.id = documentos_de_identidad.origen_id AND documentos_de_identidad.origen_type = 'User' AND documentos_de_identidad.principal = true")
    .where("lower(users.nombre || ' ' || users.apellido || ' ' || coalesce(users.email, '') || ' ' || coalesce(documentos_de_identidad.documento, '')) like lower('%#{arg}%')  AND users.estado = true AND sexo != 'i'")
    .order('users.id ASC')

    if users.length > 0
      res.set_data(users, {all: true, roles: true}, User.models_includes)
    else
      res.set_data([])
      cantidad_registros = User.where({estado: true}).count
      res.add_msg(cantidad_registros == 0 ? 'No existen empleados registrados.' : 'No existe empleado con las especificaciones introducidas.')
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

    # =========================================================================================================================================================
    def get_permisos

      joins_ = 'INNER JOIN permisos_acciones on permisos_acciones.id = roles_permisos_acciones.permiso_accion_id'
      joins_ += ' INNER JOIN acciones on acciones.id = permisos_acciones.accion_id'
      joins_ += ' INNER JOIN permisos on permisos.id = permisos_acciones.permiso_id'

      roles_permisos_acciones                    = self.roles_permisos_acciones.joins(joins_).select("roles_permisos_acciones.permiso_accion_id, CONCAT(permisos.descripcion, '_', acciones.descripcion) as permiso").group('roles_permisos_acciones.permiso_accion_id, permisos.descripcion, acciones.descripcion')

      roles_permisos_acciones
    end
    # =========================================================================================================================================================
    def  verificateHasPermiso(permiso_descripcion)
      return Permiso.verificateUserPermiso(self.id, permiso_descripcion)
    end
end
