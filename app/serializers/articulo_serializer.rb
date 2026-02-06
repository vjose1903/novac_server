class ArticuloSerializer < ActiveModel::Serializer
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
    contenido = getContentHistorico('contenidos')
    # OPTIMIZACIÓN: Solo serializar si hay contenido
    return [] if contenido.empty?
    
    serialize_parser(contenido, { all: true })
  end

  def formulas_productos_terminados
    formulas = getContentHistorico('formulas')
    # OPTIMIZACIÓN: Solo serializar si hay fórmulas
    return [] if formulas.empty?
    
    serialize_parser(formulas, { all: true })
  end

  def descripcion
    object.tipo_articulo.descripcion
  end

  def contenido
    calcularContenidos(object, true)
  end

  def cantidades
    calcularCantidades(object)
  end


  def get_param(col)
    return @instance_options[:"#{col}"]
  end

  def calcularContenidos(articulo, sacos)

    contenidos = {}

    if sacos && articulo['vendido_en'] == 'Saco' && articulo["calcular_saco"]
      [100, 50, 25].each do |c|
        contenidos["Saco_#{c}"] = c
      end
    end

    articulo['medida']                                      = articulo['medida'] == "N/A" || articulo['medida'] == nil ? object.tipo_articulo.tipo.titleize : articulo['medida']
    contenidos[articulo['medida']]                          = object.contenido_articulos.length == 0 ? 1 : object.contenido_articulos.first['cantidad']
    contenidos[object.contenido_articulos.first['medida']]  = 1 if object.contenido_articulos.length > 0


    if object.contenido_articulos.length == 2

      cantPrincipal  = 1
      cantHijo       = 1
      cantPadre      = 1

      object.contenido_articulos.each do |conte|
        cantPrincipal *= conte['cantidad']
        cantPadre = conte['cantidad'] if conte['referencia'] != nil
      end

      contenidos[articulo['medida']]                      = cantPrincipal
      contenidos[object.contenido_articulos[0]['medida']] = cantPadre
      contenidos[object.contenido_articulos[1]['medida']] = cantHijo
    end
    contenidos
  end

  def calcularCantidades(articulo)

    existencia = articulo['existencia'].nil? ? 0 : articulo['existencia']

    cantidades = {}.with_indifferent_access

    articulo['medida']                                     = articulo['medida'] == "N/A" || articulo['medida'] == nil ? object.tipo_articulo.tipo.titleize : articulo['medida']
    cantidades[articulo['medida']]                         = object.contenido_articulos.length == 0 ? existencia : (existencia / object.contenido_articulos.first['cantidad'])
    cantidades[object.contenido_articulos.first['medida']] = existencia if object.contenido_articulos.length > 0

    if object.contenido_articulos.length == 2

      maxCant   = 1
      cantPadre = 1

      object.contenido_articulos.each do | conte |
        maxCant   = conte['cantidad'] * maxCant
        cantPadre = conte['cantidad'] if conte['condicion'] == 'hijo'
      end

      cantidades[articulo['medida']]                      = (existencia / maxCant)
      cantidades[object.contenido_articulos[0]['medida']] = (existencia / cantPadre)
      cantidades[object.contenido_articulos[1]['medida']] = existencia
    end

    return cantidades
  end

  def costos
		obj = {}.with_indifferent_access

    obj["#{object.medida}"]            = {}.with_indifferent_access
    obj["#{object.medida}"]['costo']   = object.costo_principal
    obj["#{object.medida}"]['precio']  = object.precio_principal

    object.contenido_articulos.each do | conte |
      obj["#{conte.medida}"]           = {}
      obj["#{conte.medida}"]['costo']  = conte.costo
      obj["#{conte.medida}"]['precio'] = conte.precio
    end

    if object.calcular_saco && ( obj['Quintal'].present? && !obj['Quintal'].nil?)
      [100, 50, 25].each do | peso |

        obj["Saco_#{peso}"]              = {}.with_indifferent_access
        obj["Saco_#{peso}"]['costo']     = (peso / 100.to_f) * obj['Quintal']['costo']
        obj["Saco_#{peso}"]['precio']    = (peso / 100.to_f) * obj['Quintal']['precio']
      end
    end

    obj
  end

  def tipo_articulo
    object.tipo_articulo
  end

  def getContentHistorico(tipo)
    # OPTIMIZACIÓN: Usar mapa en lugar de array para acceso O(1)
    historicos_map = self.get_param('historicos_map')
    content = []

    if historicos_map.blank? || historicos_map.empty?
      # SI NO HAY HISTORICOS SE RETORNA EL ACTUAL
      content = object.contenido_articulos           if tipo == 'contenidos'
      content = object.formulas_productos_terminados if tipo == 'formulas'
    else
      # Acceso O(1) al histórico específico
      articulo = historicos_map[object.id]
      
      if articulo
        if tipo == 'contenidos'
          content = articulo['contenido_articulos'] || articulo[:contenido_articulos]
          content = articulo.contenido_articulos if content.nil? && articulo.respond_to?(:contenido_articulos)
          content ||= []
        end
        
        if tipo == 'formulas'
          content = articulo['formulas_productos_terminados'] || articulo[:formulas_productos_terminados]
          content = articulo.formulas_productos_terminados if content.nil? && articulo.respond_to?(:formulas_productos_terminados)
          content ||= []
        end
      else
        # Si no se encuentra en históricos, usar el actual
        content = object.contenido_articulos           if tipo == 'contenidos'
        content = object.formulas_productos_terminados if tipo == 'formulas'
      end
    end

    return content.nil? ? [] : content
  end
end