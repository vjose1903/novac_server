class ArticuloSerializer < ActiveModel::Serializer
  attribute :id,                                 if: Proc.new { self.personalizar_parametros('id') || self.personalizar_parametros('all') }
  attribute :imagen_id,                          if: Proc.new { self.personalizar_parametros('imagen_id') || self.personalizar_parametros('all') }
  attribute :tipo_articulo_id,                   if: Proc.new { self.personalizar_parametros('tipo_articulo_id') || self.personalizar_parametros('all') }
  attribute :nombre,                             if: Proc.new { self.personalizar_parametros('nombre') || self.personalizar_parametros('all') }
  attribute :costo_principal,                    if: Proc.new { self.personalizar_parametros('costo_principal') || self.personalizar_parametros('all') }
  attribute :precio_principal,                   if: Proc.new { self.personalizar_parametros('precio_principal') || self.personalizar_parametros('all') }
  attribute :existencia,                         if: Proc.new { self.personalizar_parametros('existencia') || self.personalizar_parametros('all') }
  attribute :aviso_existencia,                   if: Proc.new { self.personalizar_parametros('aviso_existencia') || self.personalizar_parametros('all') }
  attribute :codigo,                             if: Proc.new { self.personalizar_parametros('codigo') || self.personalizar_parametros('all') }
  attribute :fecha_ingreso,                      if: Proc.new { self.personalizar_parametros('fecha_ingreso') || self.personalizar_parametros('all') }
  attribute :medida,                             if: Proc.new { self.personalizar_parametros('medida') || self.personalizar_parametros('all') }
  attribute :is_detallable,                      if: Proc.new { self.personalizar_parametros('is_detallable') || self.personalizar_parametros('all') }
  attribute :medida_alerta,                      if: Proc.new { self.personalizar_parametros('medida_alerta') || self.personalizar_parametros('all') }
  attribute :calcular_itbis,                     if: Proc.new { self.personalizar_parametros('calcular_itbis') || self.personalizar_parametros('all') }
  attribute :estado,                             if: Proc.new { self.personalizar_parametros('estado') || self.personalizar_parametros('all') }
  attribute :is_combo,                           if: Proc.new { self.personalizar_parametros('is_combo') || self.personalizar_parametros('all') }
  attribute :otros_costos,                       if: Proc.new { self.personalizar_parametros('otros_costos') || self.personalizar_parametros('all') }
  attribute :vendido_en,                         if: Proc.new { self.personalizar_parametros('vendido_en') || self.personalizar_parametros('all') }
  attribute :is_materia_prima,                   if: Proc.new { self.personalizar_parametros('is_materia_prima') || self.personalizar_parametros('all') }

  attribute :contenido_articulos,                if: Proc.new { self.personalizar_parametros('contenido_articulos') || self.personalizar_parametros('all') }
  attribute :formulas_productos_terminados,      if: Proc.new { self.personalizar_parametros('formulas_productos_terminados') || self.personalizar_parametros('all') }

  attribute :descripcion,                        if: Proc.new { self.personalizar_parametros('descripcion') || self.personalizar_parametros('all') }

  attribute :contenido,                          if: Proc.new { self.personalizar_parametros('contenido') || self.personalizar_parametros('all') }
  attribute :cantidades,                         if: Proc.new { self.personalizar_parametros('cantidades') || self.personalizar_parametros('all') }
  attribute :calcular_saco,                      if: Proc.new { self.personalizar_parametros('calcular_saco') || self.personalizar_parametros('all') }


  def contenido_articulos
    object.contenido_articulos
    # serialize_parser(object.detalle_conduces, {all: true})
  end
  
  def formulas_productos_terminados
    object.formulas_productos_terminados
    # serialize_parser(object.cliente, {documentos_de_identidad: true, nombre: true, apellido: true, direccion: true})
  end
  
  def descripcion
    object.tipo_articulo.descripcion
  end

  def contenido
    "contenido"
  end

  def cantidades
    "cantidades"
  end






  def calcularContenidos(articulo, sacos=true)

    begin
      contenido = articulo.contenido_articulos
    rescue
      contenido = articulo["contenido_articulos"]
    end
    contenidos = {}

    if contenido.length == 0
      contenidos[articulo["medida"]] = 1
    elsif contenido.length == 1
      if articulo["vendido_en"] == "Saco" && articulo["medida"] == "Quintal"
        contenidos[articulo["medida"]] = contenido[0]["cantidad"]

        if sacos 
          contenidos["Saco_100"] = 100
          contenidos["Saco_50"] = 50
          contenidos["Saco_25"] = 25
        end

        contenidos[contenido[0]["medida"]] = 1
      else
        contenidos[articulo["medida"]] = contenido[0]["cantidad"]
        contenidos[contenido[0]["medida"]] = 1
      end
    else
      cantPrincipal = 1
      cantHijo = 1
      cantPadre = 1

      contenido.each do |conte|
        cantPrincipal *= conte["cantidad"]
        if conte["referencia"] != nil
          cantPadre = conte["cantidad"]
        end
      end

      contenidos[articulo["medida"]] = cantPrincipal
      contenidos[contenido[0]["medida"]] = cantPadre
      contenidos[contenido[1]["medida"]] = cantHijo
    end

    return contenidos
  end
  
  def personalizar_parametros(col)
		return @instance_options[:"#{col}"]
	end
end
