class ArticulosController < ApplicationController
  before_action :set_articulo, only: [:show, :update, :destroy, :checkIfExcede]

  # GET /articulos
  def index
    return Response.new(params, nil, Articulo.all.where({ estado: true}).order('id DESC'), nil, get_parametros_opcionales).send_response self
  end

  # GET /articulos/1
  def show
    return Response.new(params, nil, @articulo, nil, get_parametros_opcionales).send_response self
    # puts "aquiiiii"
    # fecha = params["fecha"] 
    # articulo = Articulo.completar_campos_articulo(fecha, params[:id])
    # # articulo = Articulo.parseal(@articulo)

    # if articulo["estado"] == false
    #   articulo = { "nombre": "Este articulo esta desactivado." }
    # end

    # render json: articulo
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
    crear_actualizar_articulo
  end
  
  def checkIfExcede
    excede = @articulo.existencia.to_f < params["cantidad"].to_f

    puts " "
    puts " "
    puts "params[cantidad].to_f     ==> ".blue + "#{params["cantidad"].to_f}"
    puts "@articulo.existencia.to_f ==> ".yellow + "#{@articulo.existencia.to_f}"
    puts "EXCEDE                    ==> ".magenta + "#{excede}"
    puts " "
    puts " "

    return Response.new(params, nil, excede, nil, nil).send_response self
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
    resultado = Articulo.filtrarArticulo(params)
    resultado.send_response self
  end

  


  # DELETE /articulos/1
  def destroy
    resultado = borrar_entidad(@articulo)
    resultado.send_response self
  end

  def get_parametros_opcionales 
    return {
      all:                            params['all'] || false,
      id:                             params['id'] || false,
      imagen_id:                      params['imagen_id'] || false,
      tipo_articulo_id:               params['tipo_articulo_id'] || false,
      nombre:                         params['nombre'] || false,
      costo_principal:                params['costo_principal'] || false,
      precio_principal:               params['precio_principal'] || false,
      existencia:                     params['existencia'] || false,
      aviso_existencia:               params['aviso_existencia'] || false,
      codigo:                         params['codigo'] || false,
      fecha_ingreso:                  params['fecha_ingreso'] || false,
      medida:                         params['medida'] || false,
      is_detallable:                  params['is_detallable'] || false,
      medida_alerta:                  params['medida_alerta'] || false,
      calcular_itbis:                 params['calcular_itbis'] || false,
      estado:                         params['estado'] || false,
      is_combo:                       params['is_combo'] || false,
      otros_costos:                   params['otros_costos'] || false,
      vendido_en:                     params['vendido_en'] || false,
      is_materia_prima:               params['is_materia_prima'] || false,
      contenido_articulos:            params['contenido_articulos'] || false,
      formulas_productos_terminados:  params['formulas_productos_terminados'] || false,
      descripcion:                    params['descripcion'] || false,
      contenido:                      params['contenido'] || false,
      cantidades:                     params['cantidades'] || false,
      calcular_saco:                  params['calcular_saco'] || false,
      costos:                         params['costos'] || false,
    }
  end


  private

  # Use callbacks to share common setup or constraints between actions.
  def set_articulo
    respuesta = set_entidad(Articulo, params)
    puts ":::::: set_articulo:::::: ".green
    @articulo = respuesta.get_data

    return respuesta.send_response self if @articulo.nil?
  end
end
