class Vehiculo < ApplicationRecord
  belongs_to :user, optional: true

  def init
    self.cantidad_viajes = 0 unless self.cantidad_viajes
  end

  def info_vehiculo
    return "#{self.marca} #{self.modelo} - #{self.anio} (#{get_propietario})"
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
      res.set_data(vehiculos, {all: true, **parametros_opcionales})
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
