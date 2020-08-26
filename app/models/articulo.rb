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

  # =====================================================================================================================
  def self.filtrarArticulo(arg)
    arg = arg === " " ? "" : arg

    select_ = "SELECT a.*, m.descripcion as modelo_descripcion, ma.descripcion as marca_descripcion, ta.descripcion as tipo_articulo_descripcion,
              s.nombre as suplidor_nombre, s.telefono as suplidor_telefono, s.direccion as suplidor_direccion, s.email as suplidor_email,
              doc.descripcion as suplidor_documento_descripcion, doc.documento as suplidor_documento_documento "

    from_ = "FROM articulos a"
    joins_ = "inner join modelos m on a.modelo_id = m.id 
              inner join tipo_articulos ta on a.tipo_articulo_id = ta.id
              inner join suplidores s on a.suplidor_id = s.id
              left join documentos_de_identidad doc on s.id = doc.suplidor_id
              inner join marcas ma on a.marca_id = ma.id"
    where_ = "where  lower(ma.descripcion|| ' '|| m.descripcion|| ' ' ||a.nombre ) like lower('%#{arg}%') AND a.estado = true"

    query = "#{select_} #{from_} #{joins_} #{where_}"

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
