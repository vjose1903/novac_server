class ArticuloSerializer < ActiveModel::Serializer
  attribute :id
  attribute :imagen_id,                          if: Proc.new { self.get_param('imagen_id') || self.get_param('all') }
  attribute :tipo_articulo_id,                   if: Proc.new { self.get_param('tipo_articulo_id') || self.get_param('all') }
  attribute :nombre,                             if: Proc.new { self.get_param('nombre') || self.get_param('all') }
  attribute :costo_principal,                    if: Proc.new { self.get_param('costo_principal') || self.get_param('all') }
  attribute :precio_principal,                   if: Proc.new { self.get_param('precio_principal') || self.get_param('all') }
  attribute :existencia,                         if: Proc.new { self.get_param('existencia') || self.get_param('all') }
  attribute :aviso_existencia,                   if: Proc.new { self.get_param('aviso_existencia') || self.get_param('all') }
  attribute :codigo,                             if: Proc.new { self.get_param('codigo') || self.get_param('all') }
  attribute :fecha_ingreso,                      if: Proc.new { self.get_param('fecha_ingreso') || self.get_param('all') }
  attribute :medida,                             if: Proc.new { self.get_param('medida') || self.get_param('all') }
  attribute :is_detallable,                      if: Proc.new { self.get_param('is_detallable') || self.get_param('all') }
  attribute :medida_alerta,                      if: Proc.new { self.get_param('medida_alerta') || self.get_param('all') }
  attribute :calcular_itbis,                     if: Proc.new { self.get_param('calcular_itbis') || self.get_param('all') }
  attribute :estado,                             if: Proc.new { self.get_param('estado') || self.get_param('all') }
  attribute :is_combo,                           if: Proc.new { self.get_param('is_combo') || self.get_param('all') }
  attribute :otros_costos,                       if: Proc.new { self.get_param('otros_costos') || self.get_param('all') }
  attribute :vendido_en,                         if: Proc.new { self.get_param('vendido_en') || self.get_param('all') }
  attribute :is_materia_prima,                   if: Proc.new { self.get_param('is_materia_prima') || self.get_param('all') }

  attribute :contenido_articulos,                if: Proc.new { self.get_param('contenido_articulos') || self.get_param('costos') || self.get_param('all') }
  attribute :formulas_productos_terminados,      if: Proc.new { object.is_combo && (self.get_param('formulas_productos_terminados') || self.get_param('all')) }

  attribute :descripcion,                        if: Proc.new { self.get_param('descripcion') || self.get_param('all') }

  attribute :contenido,                          if: Proc.new { self.get_param('contenido') || self.get_param('all') }
  attribute :cantidades,                         if: Proc.new { self.get_param('cantidades') || self.get_param('all') }
  attribute :calcular_saco,                      if: Proc.new { self.get_param('calcular_saco') || self.get_param('all') }

  attribute :costos,                             if: Proc.new { self.get_param('costos') || self.get_param('all') }


  def otros_costos
    object.otros_costos || 0
  end

  def precio_principal
    object.precio_principal
  end

  def contenido_articulos
    historicos = self.get_param('historicos')

    if historicos.blank? || historicos.empty?
      contenido = object.contenido_articulos
    else
      articulo = historicos.find  { |item| item["id"] == object.id }
      contenido = articulo["contenido_articulos"] || articulo.contenido_articulos
    end

    serialize_parser(contenido, {all: true})
  end

  def formulas_productos_terminados
    serialize_parser(object.formulas_productos_terminados, {all: true})
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

    if sacos && articulo["vendido_en"] == "Saco" && articulo["medida"] == "Quintal"
      [100, 50, 25].each do |c|
        contenidos["Saco_#{c}"] = c
      end
    end

    contenidos[articulo["medida"]] = object.contenido_articulos.length == 0 ? 1 : object.contenido_articulos.first["cantidad"]
    contenidos[object.contenido_articulos.first["medida"]] = 1 if object.contenido_articulos.length > 0


    if object.contenido_articulos.length == 2

      cantPrincipal = 1
      cantHijo = 1
      cantPadre = 1

      object.contenido_articulos.each do |conte|
        cantPrincipal *= conte["cantidad"]
        cantPadre = conte["cantidad"] if conte["referencia"] != nil
      end

      contenidos[articulo["medida"]] = cantPrincipal
      contenidos[object.contenido_articulos[0]["medida"]] = cantPadre
      contenidos[object.contenido_articulos[1]["medida"]] = cantHijo
    end
    contenidos
  end

  def calcularCantidades(articulo)

    existencia = articulo["existencia"].nil? ? 0 : articulo["existencia"]

    cantidades = {}

    cantidades[articulo["medida"]] = object.contenido_articulos.length == 0 ? existencia : (existencia / object.contenido_articulos.first["cantidad"])
    cantidades[object.contenido_articulos.first["medida"]] = existencia if object.contenido_articulos.length > 0

    if object.contenido_articulos.length == 2

      maxCant = 1
      cantPadre = 1

      object.contenido_articulos.each do |conte|
        maxCant = conte["cantidad"] * maxCant
        cantPadre = conte["cantidad"] if conte["condicion"] == "hijo"
      end

      cantidades[articulo["medida"]] = (existencia / maxCant)
      cantidades[object.contenido_articulos[0]["medida"]] = (existencia / cantPadre)
      cantidades[object.contenido_articulos[1]["medida"]] = existencia
    end

    return cantidades
  end

  def costos

    obj = {}

    obj["#{object.medida}"]            = {}
    obj["#{object.medida}"]["costo"]   = object.costo_principal
    obj["#{object.medida}"]["precio"]  = object.precio_principal
    object.contenido_articulos.each do |conte|
      obj["#{conte.medida}"]           = {}
      obj["#{conte.medida}"]["costo"]  = conte.costo
      obj["#{conte.medida}"]["precio"] = conte.precio
    end
    obj
  end

end