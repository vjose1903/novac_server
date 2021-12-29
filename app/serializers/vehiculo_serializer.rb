class VehiculoSerializer < ActiveModel::Serializer
  attribute :id,                            if: Proc.new { self.personalizar_parametros('id') || self.personalizar_parametros('all') }
  attribute :propietario,                   if: Proc.new { self.personalizar_parametros('propietario') || self.personalizar_parametros('all') }
  attribute :user_id,                       if: Proc.new { self.personalizar_parametros('user_id') || self.personalizar_parametros('all') }
  attribute :marca,                         if: Proc.new { self.personalizar_parametros('marca') || self.personalizar_parametros('all') }
  attribute :modelo,                        if: Proc.new { self.personalizar_parametros('modelo') || self.personalizar_parametros('all') }
  attribute :anio,                          if: Proc.new { self.personalizar_parametros('anio') || self.personalizar_parametros('all') }
  attribute :estado,                        if: Proc.new { self.personalizar_parametros('estado') || self.personalizar_parametros('all') }
  attribute :cantidad_viajes,               if: Proc.new { self.personalizar_parametros('cantidad_viajes') || self.personalizar_parametros('all') }
  attribute :nombre_no_empleado,            if: Proc.new { self.personalizar_parametros('nombre_no_empleado') || self.personalizar_parametros('all') }
  attribute :apellido_no_empleado,          if: Proc.new { self.personalizar_parametros('apellido_no_empleado') || self.personalizar_parametros('all') }
  attribute :telefono_no_empleado,          if: Proc.new { self.personalizar_parametros('telefono_no_empleado') || self.personalizar_parametros('all') }

  def propietario
    
    if !object.user_id.nil? 
      serialize_parser(object.user, {nombre: true, apellido: true, telefono: true})
    else
      if !object.nombre_no_empleado.nil?
        usuario={}
        usuario["nombre"]   = object.nombre_no_empleado
        usuario["apellido"] = object.apellido_no_empleado
        usuario["telefono"] = object.telefono_no_empleado
        usuario
      end
    end
  end

  def personalizar_parametros(col)
		return @instance_options[:"#{col}"]
	end
end
