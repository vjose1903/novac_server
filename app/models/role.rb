class Role < ApplicationRecord
  has_and_belongs_to_many :users, :join_table => :users_roles

  has_many :roles_permisos_acciones,           dependent: :destroy
  has_many :permisos_acciones, through: :roles_permisos_acciones
  has_many :acciones, through: :permisos_acciones

  scopify

  validates :nombre,      presence: { :message => "Debe de especificar un nombre para el rol." },       uniqueness: { scope: [:estado, :descripcion], case_sensitive: false, :message => "Este rol ya esta creado."}, :if => :estado
  validates :descripcion, presence: { :message => "Debe de especificar una descripcion para el rol." }


  def self.models_includes
    includes = [{permisos_acciones: [:permiso, :accion]}]
    return includes
  end

  def self.create_update_role(params)
    res = Response.new

    role                = Role.where(:id => params[:id]).first_or_initialize

    role.nombre         = params[:nombre]
    role.descripcion    = params[:descripcion]
    role.ruta_defecto   = params[:ruta_defecto] || nil
    role.estado         = params[:estado]

    role.valid?

    permiso_accion_ids = params[:permisos_acciones].to_a
    roles_permisos_acciones_existentes = role.id ? RolPermisoAccion.where(role_id: role.id, permiso_accion_id: permiso_accion_ids).index_by(&:permiso_accion_id) : {}

    params[:roles_permisos_acciones] = permiso_accion_ids.map do |item|
      roles_permisos_acciones_existentes[item.to_i] || {'role_id': nil, 'permiso_accion_id': item}
    end


    dependencias = [
      {modelo: RolPermisoAccion, key_object: 'roles_permisos_acciones', padre: role},
    ]

    res = crear_actualizar_dependencias(dependencias, params, false) { |key_object, dependencia_data|
      role.roles_permisos_acciones   = dependencia_data if key_object == 'roles_permisos_acciones'
    }

    if res.status_valid && role.errors.empty? && role.valid? && role.save!
      action = params[:id] ? 'actualizado' : 'creado'
      res.add_msg("Rol #{action} correctamente.")
      res.set_data(role, { all: true, permisos_acciones: true }, Role.models_includes)
    else
      res.add_msgs(role.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  def self.serialized_response(roles, params, include_permisos_acciones)
    paginate_class = Paginator.new(params)
    paginate_class.paginate_data(roles, Role.models_includes)

    res = {status: HTTP_STATUS_CODE[:ok], data: RoleSerializer.collection_to_hash(paginate_class.get_data, include_permisos_acciones: include_permisos_acciones), msg: []}
    if paginate_class.is_paginated
      res[:total_registros] = paginate_class.get_total_registros
      res[:total_paginas] = paginate_class.get_total_paginas
    end
    res
  end

  # =========================================================================================================================================================

  def self.filtrarRole(arg, params)
    arg = ActiveRecord::Base.sanitize_sql_like(arg.to_s.strip)
    serializer_params = {all: true, permisos_acciones: true}
    roles = Role
      .where(estado: true)
      .where("LOWER(COALESCE(roles.nombre, '') || ' ' || COALESCE(roles.descripcion, '')) LIKE LOWER(?)", "%#{arg}%")
      .order('roles.id ASC')

    return Response.new(params, HTTP_STATUS_CODE[:ok], roles, [], serializer_params, Role.models_includes) if roles.exists?

    res = Response.new(params)
    res.set_data([])
    cantidad_registros = Role.where({estado: true}).count
    res.add_msg(cantidad_registros == 0 ? 'No existen roles registrados.' : 'No existen roles con las especificaciones introducidas')
    res.set_status(HTTP_STATUS_CODE[:conflict])
    res
  end


end
