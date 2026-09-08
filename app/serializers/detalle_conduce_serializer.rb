class DetalleConduceSerializer < ActiveModel::Serializer
  extend FastSerializer

  

  def self.to_hash(object, params={})
    serializer = new(object, params)
    fields = default_fields.select { |field| show_serialized_field?(params, field) }
    serialize_record(object, fields, readers: readers(serializer))
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id, :cabecera_conduce_id, :detalle_factura_id, :articulo_id, :cantidad, :cantidad_en_unidades, :articulo, :descripcion, :unidad, :peso_saco]
  end

  def self.readers(serializer)
    {
      articulo: ->(_record) { serializer.articulo },
      descripcion: ->(_record) { serializer.descripcion },
      unidad: ->(_record) { serializer.unidad },
      peso_saco: ->(_record) { serializer.peso_saco }
    }
  end

  def articulo
    object.articulo.nombre
  end
  
  def descripcion
    @unidad_en_turno          = object.unidad.split(" ")

    descripcion               = @unidad_en_turno.length > 1 ? "#{object.articulo.nombre} (#{@unidad_en_turno[2]} LBS)" : object.articulo.nombre
  end
  
  def unidad
    @unidad_en_turno          ||= object.unidad.split(" ")

    object.unidad             = @unidad_en_turno.length > 1  ? @unidad_en_turno[0] : object.unidad
  end
  
  def peso_saco
    @unidad_en_turno          ||= object.unidad.split(" ")

    peso_saco                 = @unidad_en_turno.length > 1 ? @unidad_en_turno[2] : nil
  end
	
end
