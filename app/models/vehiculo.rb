class Vehiculo < ApplicationRecord
  belongs_to :user, optional: true
  after_initialize :init, if: :new_record?

  def init
    self.cantidad_viajes = 0    unless self.cantidad_viajes
    self.estado          = true unless self.id
  end

  def info_vehiculo
    "#{self.marca} #{self.modelo} - #{self.anio} (#{get_propietario})"
  end

  def marca_modelo_anio
    "#{self.marca} #{self.modelo} - #{self.anio}"
  end

  def self.models_includes
    includes = [:user]
    return includes
  end

  def self.crear_actualizar_vehiculo(params, is_save=false)
    res = Response.new

    vehiculo                         = Vehiculo.where(:id => params[:id]).first_or_initialize

    vehiculo.user_id                 = params[:user_id]                if params.obj_has?(:user_id)
    vehiculo.marca                   = params[:marca]                  if params.obj_has?(:marca)
    vehiculo.modelo                  = params[:modelo]                 if params.obj_has?(:modelo)
    vehiculo.anio                    = params[:anio]                   if params.obj_has?(:anio)
    vehiculo.nombre_no_empleado      = params[:nombre_no_empleado]     if params.obj_has?(:nombre_no_empleado)
    vehiculo.apellido_no_empleado    = params[:apellido_no_empleado]   if params.obj_has?(:apellido_no_empleado)
    vehiculo.telefono_no_empleado    = params[:telefono_no_empleado]   if params.obj_has?(:telefono_no_empleado)

    vehiculo.valid?

    if vehiculo.errors.empty? && (!is_save || (is_save && vehiculo.save!))
      res.set_data(vehiculo, {all: true}, Vehiculo.models_includes)
    else
      res.add_msgs(vehiculo.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

	def get_propietario
    propietario = nil

    if !self.user_id.nil?
      propietario =  self.user.nombre_completo
    else
      nombre    = self.nombre_no_empleado.capitalize
      nombre    += " #{self.apellido_no_empleado.capitalize}" unless self.apellido_no_empleado.blank?
      nombre    = nombre.gsub("  ", " ").strip

      propietario =  nombre
    end

    return propietario
  end
  # =====================================================================================================================


  def self.filtrarVehiculo(arg, params, parametros_opcionales)
    res = Response.new(params)

    vehiculos = Vehiculo
    .joins("left join users on vehiculos.user_id = users.id")
    .where("lower(coalesce(users.nombre, '') || ' ' || coalesce(users.apellido, '') || ' ' || vehiculos.marca || ' ' || vehiculos.modelo || ' ' || coalesce(vehiculos.nombre_no_empleado, '') || ' ' || coalesce(vehiculos.apellido_no_empleado, '')) like lower('%#{arg}%') AND vehiculos.estado = true")
    .order("vehiculos.id DESC").to_a

    if vehiculos.length > 0
      res.set_data(vehiculos, {all: true, **parametros_opcionales}, Vehiculo.models_includes)
    else
      cantidad_registros = Vehiculo.where({estado: true}).count
      res.add_msg(cantidad_registros == 0 ? "No existen vehículos registrados." : "No existen vehiculos con las especificaciones introducidas")
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end
  # ==========================================================================================

  def ajustarCantViaje(signo)
    res                = Response.new
    newCant = signo == "+" ? self.cantidad_viajes + 1 : self.cantidad_viajes - 1
    unless self.update({ cantidad_viajes: newCant})
      res.add_msgs(self.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

end
