class Articulo < ApplicationRecord
  belongs_to :tipo_articulo
  belongs_to :imagen, optional: true

  has_many :contenido_articulos, dependent: :destroy
  has_many :formulas_productos_terminados, dependent: :destroy

  attribute :contenido_articulos
  # attribute :tipo_articulo

  accepts_nested_attributes_for :imagen
  accepts_nested_attributes_for :contenido_articulos, :allow_destroy => true
  accepts_nested_attributes_for :formulas_productos_terminados, :allow_destroy => true

  validates :nombre, presence: { :message => "Nombre articulo no puede estar vacio." }, uniqueness: { case_sensitive: false, :message => "Articulo ya esta registrado" }

  def self.get_articulos_formateado
    return ActiveRecord::Base.connection.exec_query("SELECT a.id, a.nombre, ta.descripcion as tipo_articulo, a.costo_principal, a.precio_principal, a.existencia, a.codigo, a.fecha_ingreso, a.medida, a.is_detallable, ca.*, a.created_at, a.updated_at from articulos a INNER JOIN tipo_articulos ta on a.tipo_articulo_id = ta.id INNER JOIN contenido_articulos ca on ca.articulo_id = a.id")
  end
  # =====================================================================================================================
  def self.delete_articulo(id)
    return ActiveRecord::Base.connection.exec_query("UPDATE articulos SET estado=#{false} WHERE id=#{id}")
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
    att = objeto.attributes
    att["descripcion"] = objeto.tipo_articulo.descripcion
    att["contenido_articulos"] = objeto.contenido_articulos
    att["contenido"] = calcularContenidos(objeto.contenido_articulos, objeto)
    att["cantidades"] = calcularCantidades(objeto.contenido_articulos, objeto)
    if att["isCombo"]
      att["formulas_productos_terminados"] = objeto.formulas_productos_terminados
    end
    return att
  end
  # =====================================================================================================================
  def self.parsealHistorico(objeto)
    puts '--------------------- inicio parsealHistorico ---------------------'
    puts ''
    puts "======".cyan * 20
    puts objeto.to_json
    puts "======".cyan * 20
    objeto["descripcion"] = objeto["descripcion"]
    objeto["contenido_articulos"] = objeto["contenido_articulos"]
    objeto["contenido"] = calcularContenidosHistorico(objeto["contenido_articulos"], objeto)
    objeto["cantidades"] = calcularCantidadesHistorico(objeto["contenido_articulos"], objeto)
    # if objeto["isCombo"]
    #   objeto["formulas_productos_terminados"] = objeto["formulas_productos_terminados"]
    # end
    puts '--------------------- fin parsealHistorico ---------------------'
    puts ' '
    puts ' '
    return objeto
  end

  # =====================================================================================================================

  def self.calcularContenidos(contenido, articulo)
    puts " ------------------- inicio calcularContenidos -------------------"
    contenidos = {}
    puts "[][][]".yellow * 20
    puts "        Articulo"
    puts "-------".yellow * 20
    puts articulo.to_json
    puts "[][][]".yellow * 20
    if contenido.length == 0
      contenidos[articulo.medida] = 1
    elsif contenido.length == 1
      contenidos[articulo.medida] = contenido[0]["cantidad"]
      contenidos[contenido[0]["medida"]] = 1
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
      
      contenidos[articulo.medida] = cantPrincipal
      contenidos[contenido[0]["medida"]] = cantPadre
      contenidos[contenido[1]["medida"]] = cantHijo
    end
    
    puts " ------------------- fin calcularContenidos -------------------"
    puts " "
    puts " "
    return contenidos
  end
  def self.calcularContenidosHistorico(contenido, articulo)
    puts " ------------------- inicio calcularContenidosHistorico -------------------"
    contenidos = {}
    puts "[][][]".yellow * 20
    puts "        Articulo"
    puts "-------".yellow * 20
    puts articulo.to_json
    puts "[][][]".yellow * 20
    if contenido.length == 0
      contenidos[articulo["medida"]] = 1
    elsif contenido.length == 1
      contenidos[articulo["medida"]] = contenido[0]["cantidad"]
      contenidos[contenido[0]["medida"]] = 1
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
    
    puts " ------------------- fin calcularContenidosHistorico -------------------"
    puts " "
    puts " "
    return contenidos
  end
  
  # =====================================================================================================================
  
  def self.calcularCantidades(contenido, articulo)
    existencia = articulo["existencia"]
    if contenido == nil
      contenido = articulo["contenido_articulos"]
    end

    if existencia == nil
      existencia = 0
    end
    cantidades = {}

    if contenido.length == 0
      cantidades[articulo.medida] = existencia
    elsif contenido.length == 1
      cantidades[articulo.medida] = (existencia / contenido[0]["cantidad"])
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

      cantidades[articulo.medida] = (existencia / maxCant)
      cantidades[contenido[0]["medida"]] = (existencia / cantPadre)
      cantidades[contenido[1]["medida"]] = existencia
    end

    return cantidades
  end
  def self.calcularCantidadesHistorico(contenido, articulo)
    existencia = articulo["existencia"]
    if contenido == nil
      contenido = articulo["contenido_articulos"]
    end

    if existencia == nil
      existencia = 0
    end
    cantidades = {}

    if contenido.length == 0
      cantidades[articulo["medida"]] = existencia
    elsif contenido.length == 1
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
