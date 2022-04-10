class Articulo < ApplicationRecord
  belongs_to :tipo_articulo
  belongs_to :imagen, optional: true

  has_many :contenido_articulos,           dependent: :destroy
  has_many :formulas_productos_terminados, dependent: :destroy

  attribute :contenido_articulos
  attribute :formulas_productos_terminados

  # has_many :imagen
  accepts_nested_attributes_for :contenido_articulos

  validates :nombre,              presence: { :message => "Nombre articulo no puede estar vacio." },         uniqueness: { scope: :estado, case_sensitive: false, :message => "Articulo ya esta registrado" }, :if => :estado
  validates :medida,              presence: { :message => "Medida articulo no puede estar vacio." }
  validates :vendido_en,          presence: { :message => "Debe de especificar en que medida se vende el articulo." }
  validates :costo_principal,     presence: { :message => "El costo del articulo no puede estar vacio." },   numericality: { greater_than: 0, :message => "El costo del articulo debe de ser mayor a 0." }
  validates :precio_principal,    presence: { :message => "El precio del articulo no puede estar vacio." },  numericality: { greater_than: 0, :message => "El precio del articulo debe de ser mayor a 0." }

  # before_validation :otras_validaciones

  def otras_validaciones
  end


  def self.create_update_articulo(params, articulo_antiguo, is_save=false)
		res = Response.new
    Articulo.transaction do

      ant_articulo                              =  articulo_antiguo.nil? ? nil : articulo_antiguo
      ant_articulo_contenido                    =  articulo_antiguo.nil? ? nil : articulo_antiguo.contenido_articulos
      ant_articulo_formula                      =  articulo_antiguo.nil? ? nil : articulo_antiguo.formulas_productos_terminados
      ant_articulo_otro_costo                   =  articulo_antiguo.nil? ? nil : articulo_antiguo.otros_costos_articulos


      unless params["id"]
        articulo                                = Articulo.new
      else
        articulo                                = Articulo.find_by_id(params["id"])
      end

      articulo.tipo_articulo_id                 = params["tipo_articulo_id"]
      articulo.nombre                           = params["nombre"]
      articulo.estado                           = params["estado"]
      articulo.costo_principal                  = params["costo_principal"]
      articulo.precio_principal                 = params["precio_principal"]
      articulo.medida_alerta                    = params["medida_alerta"]
      articulo.existencia                       = params["existencia"]
      articulo.codigo                           = params["codigo"]
      articulo.fecha_ingreso                    = params["fecha_ingreso"]
      articulo.medida                           = params["medida"]
      articulo.is_detallable                    = params["is_detallable"]
      articulo.aviso_existencia                 = params["aviso_existencia"]
      articulo.calcular_itbis                   = params["calcular_itbis"]
      articulo.is_combo                         = params["is_combo"]
      articulo.otros_costos                     = params["otros_costos"]
      articulo.vendido_en                       = params["vendido_en"]
      articulo.is_materia_prima                 = params["is_materia_prima"]
      articulo.calcular_saco                    = params["calcular_saco"]
      articulo.imagen_id                        = params["imagen_id"]

      # imagen_attributes

      dependencias = [
        {modelo: ContenidoArticulo,          key_object: "contenido_articulos",           padre: articulo},
        {modelo: FormulasProductosTerminado, key_object: "formulas_productos_terminados", padre: articulo},
        {modelo: OtroCostoArticulo,          key_object: "otros_costos_articulos",        padre: articulo},
      ]

      res = crear_actualizar_dependencias(dependencias, params, false) { |key_object, dependencia_data|
        articulo.formulas_productos_terminados   = dependencia_data if key_object == 'formulas_productos_terminados'
        articulo.contenido_articulos             = dependencia_data if key_object == 'contenido_articulos'
        articulo.otros_costos_articulos          = dependencia_data if key_object == 'otros_costos_articulos'
      }



      res = articulo.set_contenido_referencia_and_codigo() if res.status_valid && articulo.errors.empty? && articulo.valid?&& articulo.save!


      if res.status_valid && articulo.errors.empty?

        if ant_articulo.nil?
          ant_articulo                = articulo
          ant_articulo_contenido      = ant_articulo.contenido_articulos
          ant_articulo_formula        = ant_articulo.formulas_productos_terminados
          ant_articulo_otro_costo     = ant_articulo.otros_costos_articulos
        end

        res_historico = MantenimientoArticulo.add_historico(ant_articulo, ant_articulo_contenido, ant_articulo_formula, ant_articulo_otro_costo)

        if res_historico.status_valid

          res.set_data(articulo)
          action = params["id"] ? 'actualizado' : 'creado'
          res.add_msg("Articulo #{action} correctamente.")
        else
          res.add_msgs(res_historico.get_msgs)
          res.set_status(HTTP_STATUS_CODE[:conflict])
        end

      else
        res.add_msgs(articulo.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      raise ActiveRecord::Rollback unless articulo.errors.empty?
    end
		return res
  end

  # =====================================================================================================================

  def set_contenido_referencia_and_codigo
    res = Response.new
    self.contenido_articulos.last.referencia    = self.contenido_articulos.first.id if self.contenido_articulos.length > 1
    self.codigo                                 = "%05d" % self.id.to_s

    unless self.save! && (self.contenido_articulos.last.nil? || (!self.contenido_articulos.last.nil? && self.contenido_articulos.last.save!))
      res.add_msgs(self.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # =====================================================================================================================


  def self.filtrarArticulo(params)
    res        = Response.new(set_paginate_options(params))
    arg        = params["arg"]
    fecha      = "#{params["fecha"]}:00"

    where      = "lower(tipo_articulos.descripcion || ' ' || articulos.nombre || ' ' || articulos.codigo ) like lower('%#{arg}%') AND articulos.estado = true "

    signo      = params["is_compra"].to_boolean ? "!=" : "="
    tipo_id    = params["is_compra"].to_boolean ? "3" : params["tipo"]

    where += "AND articulos.tipo_articulo_id #{signo} #{tipo_id} " if params["tipo"] != "todos"

    where += "OR ( articulos.is_materia_prima = true AND articulos.estado = true) " if params["tipo"] == TipoArticulos.materia_prima

    articulos_ = Articulo
    .joins("inner join tipo_articulos on articulos.tipo_articulo_id = tipo_articulos.id")
    .where(where)
    .order("articulos.id ASC")


    articulos = []
    historicos = []
    articulos_.map { |articulo|

      fecha_ultima_edicion_articulo = calculateDateUTC(articulo["updated_at"]).slice(0,17)
      fecha_ultima_edicion_articulo = "#{fecha_ultima_edicion_articulo}00"

      if fecha < fecha_ultima_edicion_articulo
        hist = MantenimientoArticulo.get_historico_by_date_mayor_or_menor(fecha, articulo.id, ">=", "ASC")

        if hist.blank?
          articulos.push(articulo)
          historicos.push(articulo)
        else
          historico = MantenimientoArticulo.crearArticuloHistorico(hist.first, articulo)
          historicos.push(historico)

          articulos.push(Articulo.new(historico))
        end
      else
        articulos.push(articulo)
        historicos.push(articulo)
      end

    }

    if articulos.length > 0
      res.set_data(articulos, {all: true, historicos: historicos})
      # res.set_data(articulos)
    else
			cantidad_registros = Articulo.where({estado: true}).count
      res.add_msg(cantidad_registros == 0 ? "No existen datos registrados." : "No existen articulos con las especificaciones introducidas")
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # =====================================================================================================================
  def self.parseal(objeto)

    begin
      att = objeto.attributes
    rescue
      att = objeto
    end

    att = att[0] if att.kind_of?(Array)
    id = att["id"]

    att["contenido_articulos"] = ContenidoArticulo.where({ articulo_id: id })
    att["formulas_productos_terminados"] = FormulasProductosTerminado.where({ articulo_id: id })

    tipoArt = TipoArticulo.find_by_id(objeto["tipo_articulo_id"])
    att["descripcion"] = tipoArt["descripcion"]
    return att
  end
  # =====================================================================================================================
  def self.parsealHistorico(objeto)

    objeto["descripcion"]              = objeto["descripcion"]
    objeto["contenido_articulos"]      = objeto["contenido_articulos"]

    objeto["contenido"]                = calcularContenidos(objeto)
    objeto["cantidades"]               = calcularCantidades(objeto)

    return objeto
  end

  def self.calcularContenidos(articulo, sacos = true )

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

  def self.calcularCantidades(articulo)
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
end
