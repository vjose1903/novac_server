class VehiculoSerializer < ActiveModel::Serializer
  extend FastSerializer

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
  attribute :marca_modelo_anio,             if: Proc.new { self.get_param('marca_modelo_anio')  }
  attribute :nombre_completo_propietario,   if: Proc.new { self.get_param('nombre_completo_propietario')  }

  def propietario
    @propietario = nil
    if !object.user_id.nil?
      usuario = serialize_parser(object.user, {nombre: true, apellido: true, telefono: true})

      @propietario = usuario
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
  end

  def marca_modelo_anio
    object.marca_modelo_anio
  end

  def nombre_completo_propietario
    unless object.user_id.nil?
      object.user.nombre_completo
    else
      nombre    = @propietario[:nombre].capitalize
      nombre    += " #{@propietario[:apellido].capitalize}" unless @propietario[:apellido].blank?
      nombre    = nombre.gsub("  ", " ").strip
      nombre
    end

  end

  def get_param(col)
    @instance_options[:"#{col}"]
  end

  def self.to_hash(object, params={})
    propietario = propietario_to_hash(object)
    readers = {
      propietario: ->(_vehiculo) { propietario },
      info_vehiculo: ->(vehiculo) { vehiculo.info_vehiculo },
      marca_modelo_anio: ->(vehiculo) { vehiculo.marca_modelo_anio },
      nombre_completo_propietario: ->(vehiculo) { nombre_completo_propietario_to_hash(vehiculo, propietario) }
    }
    fields = default_fields.select { |field| show_serialized_field?(params, field) }
    fields += optional_fields.select { |field| params[field] }
    serialize_record(object, fields, readers: readers)
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [
      :id,
      :propietario,
      :user_id,
      :marca,
      :modelo,
      :anio,
      :estado,
      :cantidad_viajes,
      :nombre_no_empleado,
      :apellido_no_empleado,
      :telefono_no_empleado
    ]
  end

  def self.optional_fields
    [:info_vehiculo, :marca_modelo_anio, :nombre_completo_propietario]
  end

  def self.propietario_to_hash(object)
    if object.user_id
      return nil unless object.user

      user_data = UserSerializer.to_hash(object.user, {nombre: true, apellido: true, telefono: true})
      user_data[:nombre_completo] = object.user.nombre_completo
      user_data
    elsif object.nombre_no_empleado
      {
        nombre: object.nombre_no_empleado,
        apellido: object.apellido_no_empleado,
        telefono: object.telefono_no_empleado
      }
    end
  end

  def self.nombre_completo_propietario_to_hash(object, propietario)
    return object.user.nombre_completo if object.user_id && object.user
    return nil unless propietario

    nombre = propietario[:nombre].capitalize
    nombre += " #{propietario[:apellido].capitalize}" unless propietario[:apellido].blank?
    nombre.gsub("  ", " ").strip
  end
end
