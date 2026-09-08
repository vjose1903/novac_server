class ArticuloSerializer < ActiveModel::Serializer
  include FastSerializer
  extend FastSerializer







  def medida
    object.medida || "N/A"
  end

  def otros_costos
    object.otros_costos || 0
  end

  def precio_principal
    object.precio_principal
  end

  def contenido_articulos
    serialize_contenido_articulos(content_historico('contenidos'))
  end

  def formulas_productos_terminados
    serialize_formulas_productos_terminados(content_historico('formulas'))
  end

  def descripcion
    object.tipo_articulo.descripcion
  end

  def contenido
    Articulo.contenidos_calculados(object, true)
  end

  def cantidades
    Articulo.cantidades_calculadas(object)
  end


  def get_param(col)
    @instance_options[col.to_sym]
  end

  def costos
    Articulo.costos_calculados(object)
  end

  def tipo_articulo
    serializable_attributes(object.tipo_articulo)
  end

  def content_historico(tipo)
    historicos_map = get_param('historicos_map')
    return current_content(tipo) if historicos_map.blank?

    articulo = historicos_map[object.id]
    return current_content(tipo) unless articulo

    historico_content(articulo, tipo)
  end

  def current_content(tipo)
    return object.contenido_articulos if tipo == 'contenidos'
    return object.formulas_productos_terminados if tipo == 'formulas'

    []
  end

  def historico_content(articulo, tipo)
    key = tipo == 'contenidos' ? 'contenido_articulos' : 'formulas_productos_terminados'
    content = articulo[key] || articulo[key.to_sym]
    content = articulo.public_send(key) if content.nil? && articulo.respond_to?(key)
    content || []
  end

  def serialize_contenido_articulos(content)
    ContenidoArticuloSerializer.collection_to_hash(content, { all: true })
  end

  def serialize_formulas_productos_terminados(formulas)
    FormulasProductosTerminadoSerializer.collection_to_hash(formulas, { all: true })
  end

  def serializable_attributes(record)
    return nil unless record
    return record.attributes if record.respond_to?(:attributes)

    record
  end

  def self.to_hash(object, params={})
    serializer = new(object, params)
    fields = [:id]
    fields += optional_fields.select do |field|
      params[:all] || params[field] || (field == :contenido_articulos && params[:costos]) || (field == :formulas_productos_terminados && object.is_combo && params[:formulas_productos_terminados])
    end

    serialize_record(object, fields, readers: serializer_readers(serializer))
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.optional_fields
    [
      :imagen_id,
      :tipo_articulo_id,
      :nombre,
      :costo_principal,
      :precio_principal,
      :existencia,
      :aviso_existencia,
      :codigo,
      :fecha_ingreso,
      :medida,
      :is_detallable,
      :medida_alerta,
      :calcular_itbis,
      :estado,
      :is_combo,
      :otros_costos,
      :vendido_en,
      :is_materia_prima,
      :contenido_articulos,
      :formulas_productos_terminados,
      :descripcion,
      :contenido,
      :cantidades,
      :calcular_saco,
      :costos,
      :tipo_articulo
    ]
  end

  def self.serializer_readers(serializer)
    {
      medida: ->(_articulo) { serializer.medida },
      otros_costos: ->(_articulo) { serializer.otros_costos },
      precio_principal: ->(_articulo) { serializer.precio_principal },
      contenido_articulos: ->(_articulo) { serializer.contenido_articulos },
      formulas_productos_terminados: ->(_articulo) { serializer.formulas_productos_terminados },
      descripcion: ->(_articulo) { serializer.descripcion },
      contenido: ->(_articulo) { serializer.contenido },
      cantidades: ->(_articulo) { serializer.cantidades },
      costos: ->(_articulo) { serializer.costos },
      tipo_articulo: ->(_articulo) { serializer.tipo_articulo }
    }
  end
end
