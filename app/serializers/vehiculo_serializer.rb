class VehiculoSerializer < ActiveModel::Serializer
  extend FastSerializer








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
