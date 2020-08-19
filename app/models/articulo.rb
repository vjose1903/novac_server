class Articulo < ApplicationRecord
  belongs_to :suplidor
  belongs_to :marca
  belongs_to :modelo
  belongs_to :tipo_articulo

  has_many :contenido_articulos, dependent: :destroy

  attribute :marca
  attribute :modelo
  attribute :tipo_articulo
  attribute :suplidor
  attribute :contenido_articulos

  accepts_nested_attributes_for :contenido_articulos, :allow_destroy => true

  validates :nombre, presence: { :message => "Nombre articulo no puede estar vacio." }, uniqueness: { case_sensitive: false, :message => "Articulo ya esta registrado" }

<<<<<<< HEAD
  # =====================================================================================================================
  def self.filtrarArticulo(arg)
    arg = arg === " " ? "" : arg

    select_ = "SELECT a.*, m.descripcion as modelo_descripcion, ma.descripcion as marca_descripcion, ta.descripcion as tipo_articulo_descripcion,
              s.nombre as suplidor_nombre, s.telefono as suplidor_telefono, s.direccion as suplidor_direccion, s.email as suplidor_email,
              doc.descripcion as suplidor_documento_descripcion, doc.documento as suplidor_documento_documento "

=======
  def self.get_articulos_formateado
    return my_query("SELECT a.id, a.nombre, ta.descripcion as tipo_articulo, a.costo_principal, a.precio_principal, a.existencia, a.codigo, a.fecha_ingreso, a.medida, a.is_detallable, ca.*, a.created_at, a.updated_at from articulos a INNER JOIN tipo_articulos ta on a.tipo_articulo_id = ta.id INNER JOIN contenido_articulos ca on ca.articulo_id = a.id")
  end
  # =====================================================================================================================
  def self.filtrarArticulo(arg)
    arg = arg === " " ? "" : arg
    # inner join suplidores s on a.suplidor_id = s.id
    # left join documentos_de_identidad doc on s.id = doc.suplidor_id
    # || ' ' || s.nombre || ' ' || coalesce(doc.documento, '')

    select_ = "SELECT a.*, ta.descripcion as tipo_articulo_descripcion,
                img.file_name as file_name, img.base_64 as base_64, img.path as path "

    from_ = "FROM articulos a"
    joins_ = "inner join tipo_articulos ta on a.tipo_articulo_id = ta.id
              left join imagenes img on img.id = a.imagen_id"
    where_ = "where  lower(ta.descripcion || ' ' || a.nombre ) like lower('%#{arg}%') AND a.estado = true"
    order_ = "ORDER BY a.id ASC"

    query = "#{select_} #{from_} #{joins_} #{where_} #{order_}"

    my_query(query)
  end

  # =====================================================================================================================
  def self.parsearArticulosFiltro(articulos)
    articulos.each do |arti|
      arti["descripcion"] = arti["tipo_articulo_descripcion"]

      arti["imagen"] = { file_name: arti["file_name"], base_64: arti["base_64"], path: arti["path"] }

      # arti["suplidor"] = { id: arti["suplidor_id"], nombre: arti["suplidor_nombre"], telefono: arti["suplidor_telefono"],
      #                     direccion: arti["suplidor_direccion"], email: arti["suplidor_email"],
      #                     documento_de_identidad: {
      #   id: arti["suplidor_id"],
      #   descripcion: arti["suplidor_documento_descripcion"],
      #   documento: arti["suplidor_documento_documento"],
      # } }

      arti.delete("tipo_articulo_descripcion")
      arti.delete("path")
      arti.delete("base_64")
      arti.delete("file_name")

      # arti.delete("suplidor_nombre")
      # arti.delete("suplidor_nombre")
      # arti.delete("suplidor_telefono")
      # arti.delete("suplidor_direccion")
      # arti.delete("suplidor_email")
      # arti.delete("suplidor_documento_descripcion")
      # arti.delete("suplidor_documento_documento")
    end

    return articulos
  end

  # =====================================================================================================================
  def self.get_articulo_by_name_o_by_codigo(tipo, nombre)
    select_ = "SELECT id, tipo_articulo_id, nombre, costo_principal, precio_principal, existencia, codigo, fecha_ingreso, medida, is_detallable, created_at, updated_at, imagen_id, aviso_existencia, suplidor_id, medida_alerta, calcular_itbis, estado, is_combo, otros_costos"
>>>>>>> prueba
    from_ = "FROM articulos a"
    joins_ = "inner join modelos m on a.modelo_id = m.id 
              inner join tipo_articulos ta on a.tipo_articulo_id = ta.id
              inner join suplidores s on a.suplidor_id = s.id
              left join documentos_de_identidad doc on s.id = doc.suplidor_id
              inner join marcas ma on a.marca_id = ma.id"
    where_ = "where  lower(ma.descripcion|| ' '|| m.descripcion|| ' ' ||a.nombre ) like lower('%#{arg}%') AND a.estado = true"

    query = "#{select_} #{from_} #{joins_} #{where_}"

<<<<<<< HEAD
    my_query(query)
  end

  # =====================================================================================================================

  def self.parsearArticulosFiltro(articulos)
    articulos.each do |arti|
      arti["marca"] = { id: arti["marca_id"], descripcion: arti["marca_descripcion"] }
      arti["modelo"] = { id: arti["modelo_id"], descripcion: arti["modelo_descripcion"] }
      arti["tipo_articulo"] = { id: arti["tipo_articulo_id"], descripcion: arti["tipo_articulo_descripcion"] }

      arti["suplidor"] = { id: arti["suplidor_id"], nombre: arti["suplidor_nombre"], telefono: arti["suplidor_telefono"],
                          direccion: arti["suplidor_direccion"], email: arti["suplidor_email"],
                          documento_de_identidad: {
        id: arti["suplidor_id"],
        descripcion: arti["suplidor_documento_descripcion"],
        documento: arti["suplidor_documento_documento"],
      } }

      arti.delete("marca_descripcion")
      arti.delete("modelo_descripcion")
      arti.delete("tipo_articulo_descripcion")

      arti.delete("suplidor_nombre")
      arti.delete("suplidor_nombre")
      arti.delete("suplidor_telefono")
      arti.delete("suplidor_direccion")
      arti.delete("suplidor_email")
      arti.delete("suplidor_documento_descripcion")
      arti.delete("suplidor_documento_documento")
    end

    return articulos
=======
    query = "#{select_} #{from_} #{where_}"
    return my_query(query)
  end

  # =====================================================================================================================
  def self.delete_articulo(id)
    return my_query("UPDATE articulos SET estado=#{false} WHERE id=#{id}")
>>>>>>> prueba
  end

  # =====================================================================================================================

  def self.parsearArticulos(arti)
    marca = Marca.find_by_id(arti["marca_id"].to_i)
    modelo = Modelo.find_by_id(arti["modelo_id"].to_i)
    tipo_articulo = TipoArticulo.find_by_id(arti["tipo_articulo_id"].to_i)

    suplidor = Suplidor.find_by_id(arti["suplidor_id"].to_i)
    suplidor_doc = DocumentoDeIdentidad.find_by_suplidor_id(arti["suplidor_id"].to_i)

    # contenido = ContenidoArticulo.find_by_articulo_id(arti["id"].to_i)

    arti["marca"] = { id: arti["marca_id"], descripcion: marca["descripcion"] }

    arti["modelo"] = { id: arti["modelo_id"], descripcion: modelo["descripcion"] }

    arti["suplidor"] = { id: arti["suplidor_id"], nombre: suplidor["nombre"], telefono: suplidor["telefono"],
                        direccion: suplidor["direccion"], email: suplidor["email"],
                        documento_de_identidad: {
      id: suplidor_doc["id"],
      descripcion: suplidor_doc["descripcion"],
      documento: suplidor_doc["documento"],
    } }

    arti["tipo_articulo"] = { id: arti["tipo_articulo_id"], descripcion: tipo_articulo["descripcion"] }
    # arti["contenido_articulos"] = contenido

    return arti
  end

  # =====================================================================================================================
<<<<<<< HEAD

  def self.get_articulo_by_name_o_by_codigo(tipo, nombre)
    select_ = "SELECT *"
    from_ = "FROM articulos a"
    where_ = ""

    if (tipo == "nombre")
      where_ = " WHERE lower(#{tipo}) like lower('#{nombre}%') AND estado = true"
    else
      where_ = " WHERE #{tipo} = '#{nombre}' AND estado = true"
    end

    query = "#{select_} #{from_} #{where_}"
    return my_query(query)
  end

  # =====================================================================================================================
  def self.delete_articulo(id)
    return my_query("UPDATE articulos SET estado=#{false} WHERE id=#{id}")
=======
  def self.parseal(objeto)
    begin
      att = objeto.attributes
    rescue
      att = objeto
    end
    tipoArt = TipoArticulo.find_by_id(objeto["tipo_articulo_id"])
    att["descripcion"] = tipoArt["descripcion"]
    return att
>>>>>>> prueba
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
