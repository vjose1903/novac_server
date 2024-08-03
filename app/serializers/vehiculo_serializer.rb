class VehiculoSerializer < ActiveModel::Serializer
  attribute :id,                            if: Proc.new { self.get_param('id') || self.get_param('all') }
  attribute :propietario,                   if: Proc.new { self.get_param('propietario') || self.get_param('all') }
  attribute :user_id,                       if: Proc.new { self.get_param('user_id') || self.get_param('all') }
  attribute :marca,                         if: Proc.new { self.get_param('marca') || self.get_param('all') }
  attribute :modelo,                        if: Proc.new { self.get_param('modelo') || self.get_param('all') }
  attribute :anio,                          if: Proc.new { self.get_param('anio') || self.get_param('all') }
  attribute :estado,                        if: Proc.new { self.get_param('estado') || self.get_param('all') }
  attribute :cantidad_viajes,               if: Proc.new { self.get_param('cantidad_viajes') || self.get_param('all') }
  attribute :nombre_no_empleado,            if: Proc.new { self.get_param('nombre_no_empleado') || self.get_param('all') }
  attribute :apellido_no_empleado,          if: Proc.new { self.get_param('apellido_no_empleado') || self.get_param('all') }
  attribute :telefono_no_empleado,          if: Proc.new { self.get_param('telefono_no_empleado') || self.get_param('all') }

  attribute :info_vehiculo,                 if: Proc.new { self.get_param('info_vehiculo')  }
  attribute :nombre_completo_propietario,   if: Proc.new { self.get_param('nombre_completo_propietario')  }

  def propietario
    @propietario = nil
    puts "\n\n----- ANDO AQUII PROPIETARIO ----\n\n".red
    if !object.user_id.nil?
      @propietario = serialize_parser(object.user, {nombre: true, apellido: true, telefono: true})
      puts "@propietario".yellow + " #{@propietario.to_json}"
    else
      unless object.nombre_no_empleado.nil?
        usuario             = {}
        usuario[:nombre]   = object.nombre_no_empleado
        usuario[:apellido] = object.apellido_no_empleado
        usuario[:telefono] = object.telefono_no_empleado
        @propietario        = usuario
        usuario
      end
    end
  end

  def info_vehiculo
    object.info_vehiculo
    puts "object.info_vehiculo".yellow + " #{object.info_vehiculo.to_json}"
  end

  def nombre_completo_propietario
    unless object.user_id.nil?
      object.user.nombre_completo

      puts "object.user.nombre_completo".yellow + " #{object.user.nombre_completo}"
    else
      nombre    = @propietario[:nombre].capitalize
      nombre    += " #{@propietario[:apellido].capitalize}" unless @propietario[:apellido].blank?
      nombre    = nombre.gsub("  ", " ").strip
      nombre
    end

  end

  def get_param(col)
    return @instance_options[:"#{col}"]
  end
end
