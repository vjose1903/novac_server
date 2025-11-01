class FormulasProductosTerminadoSerializer < ActiveModel::Serializer
  attribute :id,                        if: Proc.new { self.get_param('all') || self.get_param('id') }
  attribute :articulo_id,               if: Proc.new { self.get_param('all') || self.get_param('articulo_id') }
  attribute :cantidad,                  if: Proc.new { self.get_param('all') || self.get_param('cantidad') }
  attribute :costo,                     if: Proc.new { self.get_param('all') || self.get_param('costo') }
  attribute :precio,                    if: Proc.new { self.get_param('all') || self.get_param('precio') }
  attribute :medida,                    if: Proc.new { self.get_param('all') || self.get_param('medida') }
  attribute :articulo_combo_id,         if: Proc.new { self.get_param('all') || self.get_param('articulo_combo_id')    }

  attribute :articulo_combo,            if: Proc.new { self.get_param('all') || self.get_param('articulo_combo') }
  attribute :nombre,                    if: Proc.new { self.get_param('all') || self.get_param('nombre') }
  attribute :existencia,                if: Proc.new { self.get_param('all') || self.get_param('existencia') }
  attribute :contenido,                 if: Proc.new { self.get_param('all') || self.get_param('contenido') }

  def articulo_combo
    begin
      @articulo_combo = object.articulo_combo
    rescue
      @articulo_combo = Articulo.find_by_id(object.articulo_combo_id)
    end

    @articulo_combo
  end

  def nombre
    articulo_combo_object&.nombre
  end

  def nombre
    articulo_combo_object&.nombre
  end

  def existencia
    return {} unless articulo_combo_object
    calcularCantidades(articulo_combo_object)
  end

  def contenido
    return {} unless articulo_combo_object
    calcularContenidos(articulo_combo_object)
  end

  def calcularContenidos(articulo, sacos = true)

    contenido = articulo.contenido_articulos
    contenidos = {}

    if sacos && articulo["vendido_en"] == "Saco" && articulo["calcular_saco"]
      [100, 50, 25].each do |c|
        contenidos["Saco_#{c}"] = c
      end
    end

		articulo['medida']                    = articulo['medida'] == "N/A" || articulo['medida'] == nil ? articulo.tipo_articulo.tipo.titleize : articulo['medida']
    contenidos[articulo["medida"]]        = contenido.length == 0 ? 1 : contenido.first["cantidad"]
    contenidos[contenido.first["medida"]] = 1 if contenido.length > 0


    if contenido.length == 2

      cantPrincipal = 1
      cantHijo      = 1
      cantPadre     = 1

      contenido.each do |conte|
        cantPrincipal *= conte["cantidad"]
        cantPadre   = conte["cantidad"] if conte["referencia"] != nil
      end

      contenidos[articulo["medida"]]     = cantPrincipal
      contenidos[contenido[0]["medida"]] = cantPadre
      contenidos[contenido[1]["medida"]] = cantHijo
    end
    contenidos
  end

  def calcularCantidades(articulo)
    contenido  = articulo.contenido_articulos

    existencia = articulo["existencia"].nil? ? 0 : articulo["existencia"]

    cantidades = {}

    cantidades[articulo["medida"]] = contenido.length == 0 ? existencia : (existencia / contenido.first["cantidad"])
    cantidades[contenido.first["medida"]] = existencia if contenido.length > 0

    if contenido.length == 2

      maxCant     = 1
      cantPadre   =  1

      contenido.each do |conte|
        maxCant   = conte["cantidad"] * maxCant
        cantPadre = conte["cantidad"] if conte["condicion"] == "hijo"
      end

      cantidades[articulo["medida"]]     = (existencia / maxCant)
      cantidades[contenido[0]["medida"]] = (existencia / cantPadre)
      cantidades[contenido[1]["medida"]] = existencia
    end

    return cantidades
  end

  private

  def articulo_combo_object
    # Cache por thread para evitar consultas repetidas del mismo artículo
    Thread.current[:articulos_cache] ||= {}
    
    return Thread.current[:articulos_cache][object.articulo_combo] if Thread.current[:articulos_cache].key?(object.articulo_combo)
    
    Thread.current[:articulos_cache][object.articulo_combo] = Articulo.find_by_id(object.articulo_combo)
  end

  def get_param(col)
    return @instance_options[:"#{col}"]
  end
end
