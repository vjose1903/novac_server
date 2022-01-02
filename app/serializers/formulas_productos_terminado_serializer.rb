class FormulasProductosTerminadoSerializer < ActiveModel::Serializer
  attribute :id,                        if: Proc.new { self.personalizar_parametros('id') || self.personalizar_parametros('all') }
  attribute :articulo_id,               if: Proc.new { self.personalizar_parametros('articulo_id') || self.personalizar_parametros('all') }
  attribute :cantidad,                  if: Proc.new { self.personalizar_parametros('cantidad') || self.personalizar_parametros('all') }
  attribute :costo,                     if: Proc.new { self.personalizar_parametros('costo') || self.personalizar_parametros('all') }
  attribute :articulo_combo,            if: Proc.new { self.personalizar_parametros('articulo_combo') || self.personalizar_parametros('all') }
  attribute :precio,                    if: Proc.new { self.personalizar_parametros('precio') || self.personalizar_parametros('all') }
  attribute :medida,                    if: Proc.new { self.personalizar_parametros('medida') || self.personalizar_parametros('all') }

  attribute :nombre,                    if: Proc.new { self.personalizar_parametros('nombre') || self.personalizar_parametros('all') }
  attribute :existencia,                if: Proc.new { self.personalizar_parametros('existencia') || self.personalizar_parametros('all') }
  attribute :contenido,                 if: Proc.new { self.personalizar_parametros('contenido') || self.personalizar_parametros('all') }

  def nombre
    @articulo_combo = Articulo.find_by_id(object.articulo_combo)
    @articulo_combo.nombre
  end

  def existencia
    calcularCantidades(@articulo_combo)
  end
  
  def contenido
    calcularContenidos(@articulo_combo)
  end


  def calcularContenidos(articulo, sacos = true)

    contenido = articulo.contenido_articulos
    contenidos = {}

    if sacos && articulo["vendido_en"] == "Saco" && articulo["medida"] == "Quintal"
      [100, 50, 25].each do |c|
        contenidos["Saco_#{c}"] = c 
      end
    end

    contenidos[articulo["medida"]] = contenido.length == 0 ? 1 : contenido.first["cantidad"]
    contenidos[contenido.first["medida"]] = 1 if contenido.length > 0


    if contenido.length == 2

      cantPrincipal = 1
      cantHijo = 1
      cantPadre = 1

      contenido.each do |conte|
        cantPrincipal *= conte["cantidad"]
        cantPadre = conte["cantidad"] if conte["referencia"] != nil
      end

      contenidos[articulo["medida"]] = cantPrincipal
      contenidos[contenido[0]["medida"]] = cantPadre
      contenidos[contenido[1]["medida"]] = cantHijo
    end
    contenidos
  end

  def calcularCantidades(articulo)
    contenido = articulo.contenido_articulos

    existencia = articulo["existencia"].nil? ? 0 : articulo["existencia"]

    cantidades = {}
    
    cantidades[articulo["medida"]] = contenido.length == 0 ? existencia : (existencia / contenido.first["cantidad"])
    cantidades[contenido.first["medida"]] = existencia if contenido.length > 0

    if contenido.length == 2

      maxCant = 1
      cantPadre = 1

      contenido.each do |conte|
        maxCant = conte["cantidad"] * maxCant
        cantPadre = conte["cantidad"] if conte["condicion"] == "hijo"
      end

      cantidades[articulo["medida"]] = (existencia / maxCant)
      cantidades[contenido[0]["medida"]] = (existencia / cantPadre)
      cantidades[contenido[1]["medida"]] = existencia
    end

    return cantidades
  end
  

  def personalizar_parametros(col)
    return @instance_options[:"#{col}"]
  end
end
