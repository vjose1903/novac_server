class Articulo < ApplicationRecord
  belongs_to :tipo_articulo
  belongs_to :imagen, optional: true

  has_many :contenido_articulos,           dependent: :destroy
  has_many :formulas_productos_terminados

  attribute :contenido_articulos
  attribute :formulas_productos_terminados

  # has_many :imagen
  accepts_nested_attributes_for :contenido_articulos

  validates :nombre,              presence: { :message => "Nombre articulo no puede estar vacio." },         uniqueness: { scope: :estado, case_sensitive: false, :message => "Articulo ya esta registrado" }, :if => :estado
  validates :costo_principal,     presence: { :message => "El costo del articulo no puede estar vacio." }
  validates :precio_principal,    presence: { :message => "El precio del articulo no puede estar vacio." },  numericality: { greater_than: 0, :message => "El precio del articulo debe de ser mayor a 0." }


  def otras_validaciones(params)

    tipo_articulo = TipoArticulo.find_by_id(self.tipo_articulo_id)

    if tipo_articulo.tipo == TipoArticuloType.venta_normal

      self.errors.add(:base, "Medida articulo no puede estar vacio.") if self.medida == nil
      self.errors.add(:base, "Debe de especificar en que medida se vende el articulo.") if self.vendido_en == nil
      self.errors.add(:base, "Debe de especificar una medida de alerta en venta.") if self.medida_alerta == nil
      self.errors.add(:base, "El costo del articulo debe de ser mayor a 0.") if self.costo_principal == 0

    end

    if self.medida == 'Caja' && (!params['contenido_articulos'].present? || params['contenido_articulos'].length == 0)
      self.errors.add(:base, "Los articulos comprados en caja debem de tener la cantidad especificada.")
    end

  end

  def self.models_includes
    includes = [:tipo_articulo, {contenido_articulos: :articulo}, {formulas_productos_terminados: :articulo}]
    return includes
  end

  def self.create_update_articulo(params, articulo_antiguo, is_save=false)
    res = Response.new
    Articulo.transaction do

      ant_articulo                              =  articulo_antiguo.nil? ? nil : articulo_antiguo
      ant_articulo_contenido                    =  articulo_antiguo.nil? ? nil : articulo_antiguo.contenido_articulos
      ant_articulo_formula                      =  articulo_antiguo.nil? ? nil : articulo_antiguo.formulas_productos_terminados


      articulo                                  = Articulo.where(:id => params['id']).first_or_create

      articulo.tipo_articulo_id                 = params['tipo_articulo_id']
      articulo.nombre                           = params['nombre']
      articulo.estado                           = params['estado']
      articulo.costo_principal                  = params['costo_principal']
      articulo.precio_principal                 = params['precio_principal']
      articulo.medida_alerta                    = params['medida_alerta']
      articulo.existencia                       = params['existencia']
      articulo.codigo                           = params['codigo']
      articulo.fecha_ingreso                    = params['fecha_ingreso']
      articulo.medida                           = params['medida']
      articulo.is_detallable                    = params['is_detallable']
      articulo.aviso_existencia                 = params['aviso_existencia']
      articulo.calcular_itbis                   = params['calcular_itbis']
      articulo.is_combo                         = params['is_combo']
      articulo.otros_costos                     = params['otros_costos']
      articulo.vendido_en                       = params['vendido_en']
      articulo.is_materia_prima                 = params['is_materia_prima']
      articulo.calcular_saco                    = params['calcular_saco']
      articulo.imagen_id                        = params['imagen_id']

      articulo.valid?
      articulo.otras_validaciones(params)

      # imagen_attributes

      dependencias = [
        {modelo: ContenidoArticulo,          key_object: "contenido_articulos",           padre: articulo},
        {modelo: FormulasProductosTerminado, key_object: "formulas_productos_terminados", padre: articulo},
      ]

      res = crear_actualizar_dependencias(dependencias, params, false) { |key_object, dependencia_data|
        articulo.formulas_productos_terminados   = dependencia_data if key_object == 'formulas_productos_terminados'
        articulo.contenido_articulos             = dependencia_data if key_object == 'contenido_articulos'
      }


      res = articulo.set_contenido_referencia_and_codigo() if res.status_valid && articulo.errors.empty? && articulo.save!


      if res.status_valid && articulo.errors.empty?

        if ant_articulo.nil?
          ant_articulo                = articulo
          ant_articulo_contenido      = ant_articulo.contenido_articulos
          ant_articulo_formula        = ant_articulo.formulas_productos_terminados
        end

        res_historico = MantenimientoArticulo.add_historico(ant_articulo, ant_articulo_contenido, ant_articulo_formula)

        if res_historico.status_valid

          res.set_data(articulo)
          action = params['id'] ? 'actualizado' : 'creado'
          res.add_msg("Articulo #{action} correctamente.")
        else
          res.add_msgs(res_historico.get_msgs)
          res.set_status(HTTP_STATUS_CODE[:conflict])
        end

      else
        res.add_msgs(articulo.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      raise ActiveRecord::Rollback if !articulo.errors.empty? || !res.status_valid
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
    res              = Response.new(set_paginate_options(params))
    arg              = params['arg']
    fecha            = "#{params['fecha']}:00"
    is_compra        = params['is_compra'].to_boolean
    signo            = is_compra ? "!=" : "="
    codigo_tipo      = is_compra ? TipoArticulos.producto_terminado : params['tipo']

    where            = "lower(tipo_articulos.descripcion || ' ' || articulos.nombre || ' ' || articulos.codigo ) like lower('%#{arg}%') AND articulos.estado = true "

    where += "AND tipo_articulos.codigo #{signo} '#{codigo_tipo}' #{ is_compra ? "AND tipo_articulos.tipo != '#{TipoArticuloType.servicio}'" : ""} " if params['tipo'] != "todos" || is_compra

    where += "OR ( articulos.is_materia_prima = true AND articulos.estado = true) " if params['tipo'] == TipoArticulos.materia_prima

    articulos_ = Articulo
    .joins("inner join tipo_articulos on articulos.tipo_articulo_id = tipo_articulos.id")
    .where(where).includes(models_includes)
    .order("articulos.id ASC")

    articulos = []
    historicos = []
    articulos_.map { |articulo|

      fecha_ultima_edicion_articulo = calculateDateUTC(articulo["updated_at"]).slice(0,17)
      fecha_ultima_edicion_articulo = "#{fecha_ultima_edicion_articulo}00"

      if fecha < fecha_ultima_edicion_articulo

        hist = MantenimientoArticulo.get_historico_by_date_mayor_or_menor(fecha, articulo.id, "<=", "DESC")

        if hist.blank?
          articulos.push(articulo)
          historicos.push(articulo)
        else
          historico = MantenimientoArticulo.crearArticuloHistorico(hist.first, articulo)
          historicos.push(historico)
          # TODO: aqui se estan borrando las formulas
          articulos.push(Articulo.new(historico))
        end
      else
        articulos.push(articulo)
        historicos.push(articulo)
      end

    }

    if articulos.length > 0

      articulos = params['paginado'].to_boolean ? articulos : articulos.to_activerecord_relation.includes(Articulo.models_includes)
      res.set_data(articulos, {all: true, historicos: historicos}, Articulo.models_includes)
      # res.set_data(articulos)
    else
      cantidad_registros = Articulo.where({estado: true}).count
      res.add_msg(cantidad_registros == 0 ? "No existen articulos registrados." : "No existen articulos con las especificaciones introducidas")
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

    att = att.first if att.kind_of?(Array)
    id  = att["id"]

    att["contenido_articulos"]           = ContenidoArticulo.where({ articulo_id: id })
    att["formulas_productos_terminados"] = FormulasProductosTerminado.where({ articulo_id: id })

    tipoArt            = TipoArticulo.find_by_id(objeto["tipo_articulo_id"])
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

    if sacos && articulo["vendido_en"] == "Saco" && articulo["calcular_saco"]
      [100, 50, 25].each do |c|
        contenidos["Saco_#{c}"] = c
      end
    end

    articulo['medida']                     = articulo['medida'] == "N/A" || articulo['medida'] == nil ? articulo.tipo_articulo.tipo.titleize : articulo['medida']
    contenidos[articulo["medida"]]         = contenido.length == 0 ? 1 : contenido.first["cantidad"]
    contenidos[contenido.first["medida"]]  = 1 if contenido.length > 0


    if contenido.length == 2

      cantPrincipal = 1
      cantHijo      = 1
      cantPadre     = 1

      contenido.each do |conte|
        cantPrincipal *= conte["cantidad"]
        cantPadre      = conte["cantidad"] if conte["referencia"] != nil
      end

      contenidos[articulo["medida"]]     = cantPrincipal
      contenidos[contenido[0]["medida"]] = cantPadre
      contenidos[contenido[1]["medida"]] = cantHijo
    end
    contenidos
  end

  # =====================================================================================================================

  def self.get_actual_price_detalles(params, parametros_opcionales)
    res                = Response.new()
    ids                = params[:ids].split(",").map(&:to_i)

    articulos          = Articulo.where(id: ids).includes(Articulo.models_includes)

    res.set_data(articulos, {**parametros_opcionales})

    return res
  end

  # =====================================================================================================================
  def self.calcularCantidades(articulo)
    contenido = articulo.contenido_articulos

    existencia = articulo["existencia"].nil? ? 0 : articulo["existencia"]

    cantidades = {}

    articulo['medida']                     = articulo['medida'] == "N/A" || articulo['medida'] == nil ? articulo.tipo_articulo.tipo.titleize : articulo['medida']
    cantidades[articulo["medida"]]         = contenido.length == 0 ? existencia : (existencia / contenido.first["cantidad"])
    cantidades[contenido.first["medida"]]  = existencia if contenido.length > 0

    if contenido.length == 2

      maxCant   = 1
      cantPadre = 1

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
end
