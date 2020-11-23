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
    return my_query("SELECT a.id, a.nombre, ta.descripcion as tipo_articulo, a.costo_principal, a.precio_principal, a.existencia, a.codigo, a.fecha_ingreso, a.medida, a.is_detallable, ca.*, a.created_at, a.updated_at from articulos a INNER JOIN tipo_articulos ta on a.tipo_articulo_id = ta.id INNER JOIN contenido_articulos ca on ca.articulo_id = a.id")
  end



  # =====================================================================================================================

  def self.countClientes()
    arg = arg === " " ? "" : arg
     
    select_ = "SELECT count(id)"
    from_ = "FROM articulos "
    joins_ = ""
    where_ = "where estado = true"
    order_ = ""

    query = "#{select_} #{from_} #{joins_} #{where_} #{order_}"

    my_query(query)
  end

  # =====================================================================================================================
  def self.filtrarArticulo(arg, is_compra, tipo, per_page)
    arg = arg === " " ? "" : arg

    # select_ = "SELECT a.*, ta.descripcion as tipo_articulo_descripcion,
    #             img.file_name as file_name, img.base_64 as base_64, img.path as path "
    select_ = "SELECT a.id"

    from_ = "FROM articulos a"
    joins_ = "inner join tipo_articulos ta on a.tipo_articulo_id = ta.id
              left join imagenes img on img.id = a.imagen_id"

    if is_compra
      where_ = "where  lower(ta.descripcion || ' ' || a.nombre || ' ' || a.codigo ) like lower('%#{arg}%') AND a.estado = true AND a.tipo_articulo_id != 3"
    else
      if tipo === "todos"
        where_ = "where  lower(ta.descripcion || ' ' || a.nombre || ' ' || a.codigo ) like lower('%#{arg}%') AND a.estado = true"
      else
        where_ = "where  lower(ta.descripcion || ' ' || a.nombre || ' ' || a.codigo ) like lower('%#{arg}%') AND a.estado = true AND a.tipo_articulo_id = #{tipo}"
      end
    end

    order_ = "ORDER BY a.id ASC"
    limit_ = "LIMIT #{per_page}"

    query = "#{select_} #{from_} #{joins_} #{where_} #{order_}"

    my_query(query)
  end
  # =====================================================================================================================
  def self.agruparDesagruparFiltro(buscando, array, page, per_page)
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
      res[:data].to_a.each do |arti|
        arti["contenido_articulos"] = ContenidoArticulo.where({ articulo_id: arti["id"] })
        if arti["is_combo"]
          arti["formulas_productos_terminados"] = FormulasProductosTerminado.where({ articulo_id: arti["id"] })
        end
        arti["contenido"] = calcularContenidos(arti)
        arti["cantidades"] = calcularCantidades(arti)
      end
    else
      res["contenido_articulos"] = ContenidoArticulo.where({ articulo_id: res["id"] })
      if res["is_combo"]
        res["formulas_productos_terminados"] = FormulasProductosTerminado.where({ articulo_id: res["id"] })
      end
      res["contenido"] = calcularContenidos(res)
      res["cantidades"] = calcularCantidades(res)
    end

    return res
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

  def self.calcularContenidos(articulo)
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
        contenidos["Saco_100"] = 100
        contenidos["Saco_50"] = 50
        contenidos["Saco_25"] = 25
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
