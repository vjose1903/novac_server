class Articulo < ApplicationRecord
  belongs_to :tipo_articulo
  belongs_to :imagen, optional: true

  has_many :contenido_articulos, dependent: :destroy
  has_many :formulas_productos_terminados, dependent: :destroy
  
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


  def self.create_update_articulo(params , is_save=false)
    Articulo.transaction do
      res = Response.new
      
      unless params["id"]
        articulo = Articulo.new()
      else
        articulo = Articulo.find_by_id(params["id"])
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

      res = crear_actualizar_dependencias(dependencias, params, !articulo.id.nil?) { |key_object, dependencia_data| 
        articulo.formulas_productos_terminados   = dependencia_data if key_object == 'formulas_productos_terminados'
        articulo.contenido_articulos             = dependencia_data if key_object == 'contenido_articulos'
      }

      res = articulo.set_contenido_referencia_and_codigo() if res.status_valid && articulo.save! 
      
      
      if res.status_valid 
        # res.set_data(serialize_parser(articulo,{}))
        res.set_data(articulo)        
        action = params["id"] ? 'actualizado' : 'creado'
        res.add_msg("Articulo #{action} correctamente.")
      else
        res.add_msgs(articulo.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      return res
      raise ActiveRecord::Rollback unless articulo.errors.empty? 
    end
  end
  
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

  def self.countArticulos() 
    select_ = "SELECT count(id)"
    from_ = "FROM articulos "
    joins_ = ""
    where_ = "where estado = true"
    order_ = ""

    query = "#{select_} #{from_} #{joins_} #{where_} #{order_}"

    my_query(query)[0]
  end
  
  
  # =====================================================================================================================

    def self.checkFechaCalcularSaco(fecha, articulo)
      res = false
      
      saco = Articulo.where({nombre:'Saco sistema'})
      unless saco.empty?
        
        saco = saco[0]
        is_correct = comparar_fecha(fecha.to_s, saco['created_at'].to_s ,">=")
  
        if is_correct && articulo["calcular_saco"] 
          res = true
        end
      end

      return res
    end

  # =====================================================================================================================
  def self.filtrarArticulo(arg, is_compra, tipo)
    arg = arg === " " ? "" : arg

    # select_ = "SELECT a.*, ta.descripcion as tipo_articulo_descripcion,
    #             img.file_name as file_name, img.base_64 as base_64, img.path as path "
    select_ = "SELECT a.id"

    from_ = "FROM articulos a"
    joins_ = "inner join tipo_articulos ta on a.tipo_articulo_id = ta.id
              left join imagenes img on img.id = a.imagen_id"

    if is_compra
      where_ = "where lower(ta.descripcion || ' ' || a.nombre || ' ' || a.codigo ) like lower('%#{arg}%') AND a.estado = true AND a.tipo_articulo_id != 3"
    else
      if tipo === "todos"
        where_ = "where lower(ta.descripcion || ' ' || a.nombre || ' ' || a.codigo ) like lower('%#{arg}%') AND a.estado = true"
      else
        where_ = "where lower(ta.descripcion || ' ' || a.nombre || ' ' || a.codigo ) like lower('%#{arg}%') AND a.estado = true AND a.tipo_articulo_id = #{tipo}"
      end
    end

    order_ = "ORDER BY a.id ASC"

    query = "#{select_} #{from_} #{joins_} #{where_} #{order_}"

    my_query(query)
  end
  # =====================================================================================================================
  def self.agruparDesagruparFiltro(buscando, array, page, per_page, fecha)
    res = nil
    is_array = true
    
    if buscando.numeric?
      if array.length == 1
        res = array[0] 
        is_array = false
      else
        res = array.to_a.my_paginate(page, per_page)
      end
    else
      res = array.to_a.my_paginate(page, per_page)
    end

    if is_array
      articulos_ = []
      res["data"].to_a.each do |arti|
        articulos_.push(completar_campos_articulo(fecha , arti["id"]))
      end
      res["data"] = articulos_
    else
      res = completar_campos_articulo(fecha , res["id"])
    end

    return res
  end
  
  # =====================================================================================================================
  def self.completar_campos_articulo(fecha , id)
    articulo = MantenimientoArticulo.get_one_articulo_by_date(fecha, id)[0]

    articulo["contenido_articulos"] = ContenidoArticulo.where({ articulo_id: id })
    if articulo["is_combo"]
      articulo["formulas_productos_terminados"] = FormulasProductosTerminado.where({ articulo_id: id })
    end
    articulo["contenido"] = calcularContenidos(articulo)
    articulo["cantidades"] = calcularCantidades(articulo)
    return articulo
  end
    
  # =====================================================================================================================
  def self.delete_articulo(id)
    return my_query("UPDATE articulos SET estado=#{false} WHERE id=#{id}")
  end

  # =====================================================================================================================

  def self.update_formula(params)
    params["formulas_productos_terminados_attributes"].each do |formula|
      formu = FormulasProductosTerminado.find_by_id(formula["id"])

      newFormula = {
        "articulo_id": formu["articulo_id"],
        "cantidad": formula["cantidad"],
        "articulo_combo": formula["articulo_combo"],
        "costo": formula["costo"],
      }
      unless formu.update(newFormula)
        # render json: { error: formu.errors, msg: "Error editando formula de articulo" }, status: :unprocessable_entity
        return false
      else
        return true
      end
    end
  end

  # =====================================================================================================================
  def self.parseal(objeto)
    begin
      att = objeto.attributes
    rescue
      att = objeto
    end


    att["contenido_articulos"] = ContenidoArticulo.where({ articulo_id: att["id"] })
    att["formulas_productos_terminados"] = FormulasProductosTerminado.where({ articulo_id: att["id"] })

    tipoArt = TipoArticulo.find_by_id(objeto["tipo_articulo_id"])
    att["descripcion"] = tipoArt["descripcion"]
    return att
  end
  # =====================================================================================================================
  def self.parsealHistorico(objeto)
    puts "--------------------- inicio parsealHistorico ---------------------"
    puts ""
    

    objeto["descripcion"] = objeto["descripcion"]
    objeto["contenido_articulos"] = objeto["contenido_articulos"]

    objeto["contenido"] = calcularContenidos(objeto)
    objeto["cantidades"] = calcularCantidades(objeto)

    puts "--------------------- fin parsealHistorico ---------------------"
    puts " "
    puts " "
    return objeto
  end

  # =====================================================================================================================

  def self.calcularContenidos(articulo, sacos=true)
    puts " ------------------- inicio calcularContenidos -------------------"

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

    puts " ------------------- fin calcularContenidos -------------------"
    puts " "
    puts " "
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
        puts "conte ==> ".red + "#{conte.to_json}"
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
