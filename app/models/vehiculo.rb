class Vehiculo < ApplicationRecord
  belongs_to :user, optional: true

  def init
    self.cantidad_viajes = 0 unless self.cantidad_viajes
  end
  
  # =====================================================================================================================

  
  def self.filtrarVehiculo(arg)
    arg = arg === " " ? "" : arg
    select_ = "SELECT v.*"
    from_ = "FROM vehiculos v "
    joins_ = "left join users u on v.user_id = u.id"
    where_ = "where  lower(coalesce(u.nombre, '') || ' ' || coalesce(u.apellido, '') || ' ' || v.marca || ' ' || v.modelo || ' ' || coalesce(v.nombre_no_empleado, '') || ' ' || coalesce(v.apellido_no_empleado, '')) like lower('%#{arg}%') AND v.estado = true"

    query = "#{select_} #{from_} #{joins_} #{where_}"

    my_query(query)
  end
  
  def self.parsear(vehiculos)
    puts "--------------- INICIO parsear ---------------"
    vehiculos.each do |vehiculo|
      
      puts "vehiculo ==>".red + "#{vehiculo.to_json}"
      usuario={}
      if !vehiculo["user_id"].nil? 
        user = User.find_by_id(vehiculo["user_id"])
        usuario["nombre"] = "#{user["nombre"]}".titleize 
        usuario["apellido"] =  "#{user["apellido"]}".titleize
        usuario["telefono"] = user["telefono"]

      else
        if !vehiculo["nombre_no_empleado"].nil?
          usuario["nombre"]   = vehiculo["nombre_no_empleado"]
          usuario["apellido"] = vehiculo["apellido_no_empleado"]
          usuario["telefono"] = vehiculo["telefono_no_empleado"]
        end
      end
      vehiculo['propietario'] = usuario
    end

    puts "--------------- FIN parsear ---------------"
    return vehiculos
  end
  # ==========================================================================================

  def aumentarCantViaje
    res                = Response.new
    
    unless self.update({ cantidad_viajes: self.cantidad_viajes + 1 })
      res.add_msgs(self.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res 
  end

end
