class Articulo < ApplicationRecord
  belongs_to :tipo_articulo
  belongs_to :imagen, optional: true

  has_many :contenido_articulos
  accepts_nested_attributes_for :contenido_articulos
  has_many :formulas_productos_terminados
  accepts_nested_attributes_for :formulas_productos_terminados
  
  # has_many :imagen

  validates :nombre,              presence: { :message => "Nombre articulo no puede estar vacio." },         uniqueness: { case_sensitive: false, :message => "Articulo ya esta registrado" }
  validates :medida,              presence: { :message => "Medida articulo no puede estar vacio." }
  validates :vendido_en,          presence: { :message => "Debe de especificar en que medida se vende el articulo." }
  validates :costo_principal,     presence: { :message => "El costo del articulo no puede estar vacio." },   numericality: { greater_than: 0, :message => "El costo del articulo debe de ser mayor a 0." }
  validates :precio_principal,    presence: { :message => "El precio del articulo no puede estar vacio." },  numericality: { greater_than: 0, :message => "El precio del articulo debe de ser mayor a 0." }

  # before_validation :otras_validaciones

  def otras_validaciones
    if self.tipo_articulo.descripcion.downcase != "producto terminado" && self.medida.downcase != "unidad" && self.medida.downcase != "quintal"
        self.contenido_articulos.each do |contenido_articulo|
          self.errors.add(:base, "")
        end
    end
  end


  def checkSacoSistema(articulo_nuevo)
      self.errors.add(:base, "A este articulo no se le puede editar el nombre.") if articulo_nuevo["nombre"] != 'Saco sistema'
      
      self.errors.add(:base, "A este articulo no se le puede editar la medida en que se compra.") if articulo_nuevo["medida"] != 'Unidad'
      
      self.errors.add(:base, "A este articulo no se le puede editar la medida para vender.") if articulo_nuevo["vendido_en"] != 'Unidad'
      
      self.errors.add(:base, "A este articulo no se le puede editar el tipo de articulo.") if articulo_nuevo["tipo_articulo_id"] != 4
      
      self.errors.add(:base, "Este articulo no se puede ser materia prima.") if articulo_nuevo["is_materia_prima"] 
  end
  
  
  def self.create_update_articulo(params, articulo_antiguo, is_save=false)
    Articulo.transaction do

      ant_articulo                              =  articulo_antiguo.nil? ? nil : articulo_antiguo
      ant_articulo_contenido                    =  articulo_antiguo.nil? ? nil : articulo_antiguo.contenido_articulos
      ant_articulo_formula                      =  articulo_antiguo.nil? ? nil : articulo_antiguo.formulas_productos_terminados

      res = Response.new
      
      unless params["id"]
        articulo                                = Articulo.new()
      else
        articulo                                = Articulo.find_by_id(params["id"])
        articulo.checkSacoSistema(params) if articulo.nombre == 'Saco sistema'
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

      params["contenido_articulos"]             = params["contenido_articulos_attributes"]           if params["contenido_articulos_attributes"]
      params["formulas_productos_terminados"]   = params["formulas_productos_terminados_attributes"] if params["formulas_productos_terminados_attributes"]
      
      dependencias = [
        {modelo: FormulasProductosTerminado, key_object: "formulas_productos_terminados", padre: articulo},
        {modelo: ContenidoArticulo,          key_object: "contenido_articulos",           padre: articulo},
      ]

      res = crear_actualizar_dependencias(dependencias, params, false) { |key_object, dependencia_data| 
        articulo.formulas_productos_terminados   = dependencia_data if key_object == 'formulas_productos_terminados'
        articulo.contenido_articulos             = dependencia_data if key_object == 'contenido_articulos'
      }
      res = articulo.set_contenido_referencia_and_codigo() if res.status_valid && articulo.errors.empty?  && articulo.save! 

      if res.status_valid && articulo.errors.empty? 
        # puts "ant_articulo ==> ".red + "#{ant_articulo.to_json}"
        # puts "ant_articulo.nil? ==> ".red + "#{ant_articulo.nil?}"
        
        if ant_articulo.nil?
          # puts ":::::::::::::: ENRTROOOOOO ::::::::::::::".yellow
          ant_articulo             = articulo
          ant_articulo_contenido   = ant_articulo.contenido_articulos
          ant_articulo_formula     = ant_articulo.formulas_productos_terminados
        end
      
        res_historico = MantenimientoArticulo.add_historico(ant_articulo, ant_articulo_contenido, ant_articulo_formula)
        
        if res_historico.status_valid
          # res.set_data(serialize_parser(articulo,{}))
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
      
      return res
      raise ActiveRecord::Rollback unless articulo.errors.empty? 
    end
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

    def self.checkFechaCalcularSaco(fecha, articulo)
      res = false
      
      saco = Articulo.find_by_nombre("Saco sistema")
      unless saco.nil?
        is_correct = comparar_fecha(fecha.to_s, saco['created_at'].to_s ,">=")
        res = is_correct && articulo["calcular_saco"] 
      end

      return res
    end

  # =====================================================================================================================


  def self.filtrarArticulo(params)
    res        = Response.new(params)
    
    arg        = params["arg"]
    fecha      = "#{params["fecha"]}:00"
    
    where      = "lower(tipo_articulos.descripcion || ' ' || articulos.nombre || ' ' || articulos.codigo ) like lower('%#{arg}%') AND articulos.estado = true"
    
    signo      = params["is_compra"].to_boolean ? "!=" : "="
    tipo_id    = params["is_compra"].to_boolean ? "3" : params["tipo"]
    
    where += " AND articulos.tipo_articulo_id #{signo} #{tipo_id}" if params["tipo"] != "todos"

    
    articulos_ = Articulo
    .joins("inner join tipo_articulos on articulos.tipo_articulo_id = tipo_articulos.id")
    .where(where)
    .order("articulos.id ASC")

    
    articulos = []
    
    articulos_.map { |articulo|
      
      fecha_ultima_edicion_articulo = calculateDateUTC(articulo["updated_at"]).slice(0,17)
      fecha_ultima_edicion_articulo = "#{fecha_ultima_edicion_articulo}00"
      
      if fecha < fecha_ultima_edicion_articulo
        
        hist = MantenimientoArticulo.get_historico_by_date_mayor_or_menor(fecha, articulo.id, ">=", "ASC") 
        
        if hist.blank?
          articulos.push(articulo) 
        else
          historico = MantenimientoArticulo.crearArticuloHistorico(hist.first, articulo)
          articulos.push(Articulo.new(historico.dup)) 
        end
      else
        articulos.push(articulo) 
      end
      
    }
    
    if articulos.length > 0
      res.set_data(articulos, {all: true})
    else
      res.add_msg("No existen articulos con las especificaciones introducidas")
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
    puts "parsealHistorico --> ".green + "#{objeto.to_json}"

    objeto["descripcion"]              = objeto["descripcion"]
    objeto["contenido_articulos"]      = objeto["contenido_articulos"]

    objeto["contenido"]                = calcularContenidos(objeto)
    objeto["cantidades"]               = calcularCantidades(objeto)

    return objeto
  end

  # =====================================================================================================================

  def self.calcularContenidos(articulo, sacos=true)

    puts "\n" * 3
    puts "======= ".red * 10
    puts "CALCULAR CONTENIDOS ".red + "#{articulo["nombre"]}"
    puts "======= ".red * 10
    puts "======= ".green + "#{articulo.to_json}"

    begin
      contenido = articulo.contenido_articulos
    rescue
      contenido = articulo["contenido_articulos"]
    end

    contenidos = {}
    
    if contenido.length == 0
      puts " ---------------- CONTENIDO 0 ----------------".yellow 
      contenidos[articulo["medida"]] = 1
    elsif contenido.length == 1
      puts " ---------------- CONTENIDO 1 ----------------".yellow 
      if articulo["vendido_en"] == "Saco" && articulo["medida"] == "Quintal"
        contenidos[articulo["medida"]] = contenido.first["cantidad"]
        
        if sacos 
          contenidos["Saco_100"] = 100
          contenidos["Saco_50"] = 50
          contenidos["Saco_25"] = 25
        end
        
        contenidos[contenido.first["medida"]] = 1
      else
        contenidos[articulo["medida"]] = contenido.first["cantidad"]
        contenidos[contenido.first["medida"]] = 1
      end
    else
      puts " ---------------- CONTENIDO 2 ----------------".yellow 
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

    puts "======= ".red * 10
    puts "\n" * 3

    return contenidos
  end

  # =====================================================================================================================

  def self.calcularCantidades(articulo)
    existencia = articulo["existencia"]

    begin
      contenido = articulo.contenido_articulos
    rescue
      contenido = articulo["contenido_articulos"]
    end

    if existencia == nil
      existencia = 0
    end
    
    cantidades = {}
    my_print_log("articulo ==>  #{articulo.to_json}")
    my_print_log("contenido ==>  #{contenido.to_json}")

    if contenido.length == 0
      cantidades[articulo["medida"]] = existencia
    elsif contenido.length == 1

      my_print_log("existencia ==>  #{existencia}")

      cantidades[articulo["medida"]] = (existencia / contenido[0]["cantidad"])
      cantidades[contenido[0]["medida"]] = existencia
    else
      maxCant = 1
      cantPadre = 1
      contenido.each do |conte|
        maxCant = conte["cantidad"] * maxCant
        if conte["condicion"] == "hijo"
          cantPadre = conte["cantidad"]
        end
      end

      cantidades[articulo["medida"]] = (existencia / maxCant)
      cantidades[contenido[0]["medida"]] = (existencia / cantPadre)
      cantidades[contenido[1]["medida"]] = existencia
    end

    return cantidades
  end
end
