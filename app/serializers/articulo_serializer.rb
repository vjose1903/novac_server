class ArticuloSerializer < ActiveModel::Serializer
  include FastSerializer
  extend FastSerializer

  attribute :id
  attribute :imagen_id,                          if: Proc.new { self.get_param('all') || self.get_param('imagen_id') }
  attribute :tipo_articulo_id,                   if: Proc.new { self.get_param('all') || self.get_param('tipo_articulo_id') }
  attribute :nombre,                             if: Proc.new { self.get_param('all') || self.get_param('nombre') }
  attribute :costo_principal,                    if: Proc.new { self.get_param('all') || self.get_param('costo_principal') }
  attribute :precio_principal,                   if: Proc.new { self.get_param('all') || self.get_param('precio_principal') }
  attribute :existencia,                         if: Proc.new { self.get_param('all') || self.get_param('existencia') }
  attribute :aviso_existencia,                   if: Proc.new { self.get_param('all') || self.get_param('aviso_existencia') }
  attribute :codigo,                             if: Proc.new { self.get_param('all') || self.get_param('codigo') }
  attribute :fecha_ingreso,                      if: Proc.new { self.get_param('all') || self.get_param('fecha_ingreso') }
  attribute :medida,                             if: Proc.new { self.get_param('all') || self.get_param('medida') }
  attribute :is_detallable,                      if: Proc.new { self.get_param('all') || self.get_param('is_detallable') }
  attribute :medida_alerta,                      if: Proc.new { self.get_param('all') || self.get_param('medida_alerta') }
  attribute :calcular_itbis,                     if: Proc.new { self.get_param('all') || self.get_param('calcular_itbis') }
  attribute :estado,                             if: Proc.new { self.get_param('all') || self.get_param('estado') }
  attribute :is_combo,                           if: Proc.new { self.get_param('all') || self.get_param('is_combo') }
  attribute :otros_costos,                       if: Proc.new { self.get_param('all') || self.get_param('otros_costos') }
  attribute :vendido_en,                         if: Proc.new { self.get_param('all') || self.get_param('vendido_en') }
  attribute :is_materia_prima,                   if: Proc.new { self.get_param('all') || self.get_param('is_materia_prima') }

  attribute :contenido_articulos,                if: Proc.new { self.get_param('all') || self.get_param('contenido_articulos') || self.get_param('costos') }
  attribute :formulas_productos_terminados,      if: Proc.new { self.get_param('all') || object.is_combo && (self.get_param('formulas_productos_terminados')) }

  attribute :descripcion,                        if: Proc.new { self.get_param('all') || self.get_param('descripcion') }

  attribute :contenido,                          if: Proc.new { self.get_param('all') || self.get_param('contenido') }
  attribute :cantidades,                         if: Proc.new { self.get_param('all') || self.get_param('cantidades') }
  attribute :calcular_saco,                      if: Proc.new { self.get_param('all') || self.get_param('calcular_saco') }

  attribute :costos,                             if: Proc.new { self.get_param('all') || self.get_param('costos') }
  attribute :tipo_articulo,                      if: Proc.new { self.get_param('all') || self.get_param('tipo_articulo')}


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
    return [] if formulas.empty?

    formulas.map do |formula|
      articulo_combo = articulo_combo_object(formula)

      serialize_record(formula, [:id, :articulo_id, :cantidad, :costo, :precio, :medida, :articulo_combo, :nombre, :existencia, :contenido], readers: {
        nombre: ->(_item) { articulo_combo&.nombre },
        existencia: ->(_item) { articulo_combo ? Articulo.cantidades_calculadas(articulo_combo) : {} },
        contenido: ->(_item) { articulo_combo ? Articulo.contenidos_calculados(articulo_combo) : {} }
      })
    end
  end

  def articulo_combo_object(formula)
    Thread.current[:articulos_cache] ||= {}
    combo_id = read_articulo_value(formula, :articulo_combo)
    return nil if combo_id.nil?

    return Thread.current[:articulos_cache][combo_id] if Thread.current[:articulos_cache].key?(combo_id)

    articulo_combo = if formula.respond_to?(:association) && formula.association(:articulo_combo_articulo).loaded?
      formula.articulo_combo_articulo
    elsif formula.respond_to?(:articulo_combo_articulo)
      formula.articulo_combo_articulo
    end

    Thread.current[:articulos_cache][combo_id] = articulo_combo
  end

  def serializable_attributes(record)
    return nil unless record
    return record.attributes if record.respond_to?(:attributes)

    record
  end

  def read_articulo_value(record, key)
    read_serialized_value(record, key)
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
