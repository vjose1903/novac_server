class Articulo < ApplicationRecord
  belongs_to :suplidor
  belongs_to :marca
  belongs_to :modelo
  belongs_to :tipo_articulo

  # accepts_nested_attributes_for :contenido_articulos, :allow_destroy => true
  # accepts_nested_attributes_for :formulas_productos_terminados, :allow_destroy => true

  validates :nombre, presence: { :message => "Nombre articulo no puede estar vacio." }, uniqueness: { case_sensitive: false, :message => "Articulo ya esta registrado" }

  # =====================================================================================================================

  def self.get_articulo_by_name_o_by_codigo(tipo, nombre)
    select_ = "SELECT *"
    from_ = "FROM articulos a"
    where_ = ""

    if (tipo == "nombre")
      where_ = " WHERE lower(#{tipo}) like lower('#{nombre}%') AND estado = true"
    else
      where_ = " WHERE #{tipo} like '#{nombre}' AND estado = true"
    end

    query = "#{select_} #{from_} #{where_}"
    return ActiveRecord::Base.connection.exec_query(query)
  end

  # =====================================================================================================================
  def self.delete_articulo(id)
    return ActiveRecord::Base.connection.exec_query("UPDATE articulos SET estado=#{false} WHERE id=#{id}")
  end

  # =====================================================================================================================
  def self.parseal(objeto)
    begin
      att = objeto.attributes
    rescue
      att = objeto
    end

    puts "objeto ==> ".red, att

    tipoArt = TipoArticulo.find_by_id(objeto["tipo_articulo_id"])

    att["descripcion"] = tipoArt["descripcion"]
    att["cantidades"] = calcularCantidades(contenido, objeto)
    return att
  end
  # =====================================================================================================================

  def self.parsealHistorico(objeto)
    puts "--------------------- inicio parsealHistorico ---------------------"
    puts ""

    objeto["descripcion"] = objeto["descripcion"]
    objeto["contenido_articulos"] = objeto["contenido_articulos"]
    objeto["contenido"] = calcularContenidosHistorico(objeto["contenido_articulos"], objeto)
    objeto["cantidades"] = calcularCantidadesHistorico(objeto["contenido_articulos"], objeto)
    # if objeto["is_combo"]
    #   objeto["formulas_productos_terminados"] = objeto["formulas_productos_terminados"]
    # end
    puts "--------------------- fin parsealHistorico ---------------------"
    puts " "
    puts " "
    return objeto
  end

  # =====================================================================================================================

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
