class ArticulosController < ApplicationController
  before_action :set_articulo, only: [:show, :update, :destroy]

  # GET /articulos
  def index
    # @articulos = Articulo.all
    @articulos = []
    Articulo.all.each do |articulo|
      articuloSelect = MantenimientoArticulo.get_one_articulo_by_date(objeto["fecha_equivalente"], articuloSelect["id"])
      if articulo["estado"] == true
        @articulos.push(Articulo.parseal(articuloSelect))
      end
    end
    render json: @articulos
  end

  def getArticuloCosto
    id = params["id"]
    tipo = params["tipo"]
    articulo = Articulo.find_by_id(id)

    
    costo = articulo.costo_principal
    precio = articulo.precio_principal

    obj={
      id: articulo.id
    }

    if articulo["medida"] == "Quintal" || articulo["medida"] == "Saco"
      obj["costo"] = articulo.contenido_articulos[0]["costo"]
      obj["precio"] = articulo.contenido_articulos[0]["precio"]
    elsif articulo["medida"] == "Libra"
      obj["costo"] = articulo["costo_principal"]
      obj["precio"] = articulo["precio_principal"]
    end
    

    render json: obj
  end


  def crear_actualizar_articulo
		parametros = params
		parametros["id"] = params["id"] if params["id"]

    resultado = Articulo.create_update_articulo(parametros, @articulo, true)
		resultado.send_response self
	end


  # POST /articulos
  def create
    @articulo = nil
    crear_actualizar_articulo
  end

  # PATCH/PUT /articulos/1
  def update
    puts "toyaquiii".red
    crear_actualizar_articulo
  end



  def getContenidos
    id = params["id"]
    articulo = Articulo.find_by_id(id)
    contenido = Articulo.calcularContenidos(articulo)
    

    render json: contenido
  end

  def checkIfExcede
    id = params["id"]
    cantidad = params["cantidad"]
    articulo = Articulo.find_by_id(id)

    if articulo.existencia.to_f < cantidad.to_f
      res = true
    else
      res = false
    end
    render json: { excede: res }
  end

  def getIngredientesFormula
    id = params["id"]
    articulo = Articulo.find_by_id(id)
    if articulo.nil?
      render json: { msg: "El articulo buscado no esta creado" }, status: 400
    elsif articulo.tipo_articulo_id != 3
      render json: { msg: "El tipo de articulo buscado no es un producto terminado" }, status: 400
    else
      formula = FormulasProductosTerminado.where({ articulo_id: articulo.id })
      ingredientes = []

      formula.each do |f|
        articulo_ingrediente = Articulo.find_by_id(f.articulo_combo)
        ingredientes.push({
          articulo_id: articulo_ingrediente.id,
          nombre: articulo_ingrediente.nombre,
          cantidad: f.cantidad,
          existencia: Articulo.calcularCantidades(articulo_ingrediente),
          contenido: Articulo.calcularContenidos(articulo_ingrediente),
        })
      end
      render json: ingredientes
    end
  end

  def getMateriasPrimas
    articulos = Articulo.where({ is_materia_prima: true })

    aArticulos = []
    articulos.each do |arti|
      obj = {}
      obj["nombre"] = arti["nombre"]
      obj["id"] = arti["id"]


      if arti["medida"] == "Quintal" || arti["medida"] == "Saco"
        obj["costo"] = arti.contenido_articulos[0]["costo"]
        obj["precio"] = arti.contenido_articulos[0]["precio"]
      elsif arti["medida"] == "Libra"
        obj["costo"] = arti["costo_principal"]
        obj["precio"] = arti["precio_principal"]
      end

      aArticulos.push(obj)
    end
    render json: aArticulos
  end

  def getcountArticulos
    cantidad = Articulo.all.count()
    render json: cantidad
  end


  def getProductosTerminados
    articulos = Articulo.where({ tipo_articulo_id: 3 })

    aArticulos = []
    articulos.each do |arti|
      aArticulos.push(Articulo.parseal(arti))
    end
    render json: aArticulos
  end

  def getArticulosFiltrados
    arg = params["arg"]
    page = params["page"]
    per_page = params["per_page"]
    paginado = params["paginado"] === "true" ? true : false
    is_compra = params["is_compra"] === "true" ? true : false
    fecha = params["fecha"]
    tipo = params["tipo"]

    articulos_ = [] 
    # articulos = Articulo.filtrarArticulo(arg, is_compra, tipo)

    resultado = Articulo.filtrarArticulo(params, set_paginate_options(params))

    resultado.send_response self

    # articulos = respuesta.get_data

    # res = []
    # if paginado
    #   res = Articulo.agruparDesagruparFiltro(arg, articulos, page, per_page, fecha)
    # else
      
    #   articulos.each do |arti|
    #     res.push(Articulo.completar_campos_articulo(DateTime.now.strftime("%Y-%m-%d %H:%M"), arti['id']))
    #   end
    # end

    # render json: res
  end

  # GET /articulos/1
  def show
    fecha = params["fecha"]
    articulo = Articulo.completar_campos_articulo(fecha, params[:id])
    # articulo = Articulo.parseal(@articulo)

    if articulo["estado"] == false
      articulo = { "nombre": "Este articulo esta desactivado." }
    end

    render json: articulo
  end


  # DELETE /articulos/1
  def destroy
    @articulo.destroy
  end

  def deleteArticulo
    if Articulo.delete_articulo(params[:id])
      render json: { msg: "Articulo borrado" }
    else
      render json: { msg: "error borrando articulo." }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_articulo
    respuesta = set_entidad(Articulo, params)
    @articulo = respuesta.get_data

    return respuesta.send_response self if @articulo.nil?
  end
end
