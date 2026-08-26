class ArticulosController < ApplicationController
  before_action :set_articulo, only: [:show, :update, :destroy, :checkIfExcede]

  # GET /articulos
  def index
    return Response.new(params, nil, Articulo.where({ estado: true}).order('id DESC'), nil, get_parametros_opcionales, Articulo.models_includes_by_mode(params["mode"])).send_response self
  end

  # GET /articulos/1
  def show
    return Response.new(params, nil, @articulo, nil, get_parametros_opcionales).send_response self
  end

  def getStock
    return Response.new(params, nil, { stock: Articulo.all.where({ estado: true}).count } , nil, get_parametros_opcionales).send_response self
  end

  def getActualPriceDetalles
		resultado = Articulo.get_actual_price_detalles(params, get_parametros_opcionales)
		resultado.send_response self
  end

  def crear_actualizar_articulo
		parametros = params
		parametros["id"] = params["id"] if params["id"]
    resultado = Articulo.create_update_articulo(parametros, @articulo, true)
		resultado.send_response self
	end

  def getArticulosFiltrados
    resultado = Articulo.filtrarArticulo(params)
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
		excede = false if @articulo.tipo_articulo.tipo == TipoArticuloType.servicio
    return Response.new(params, nil, excede, nil, nil).send_response self
  end


  # DELETE /articulos/1
  def destroy
    resultado = borrar_entidad(@articulo)
    resultado.send_response self
  end

  def get_parametros_opcionales
    return {
      all:                            validate_optional_param(params, 'all') ?                           params['all'].to_boolean :                           false,
      imagen_id:                      validate_optional_param(params, 'imagen_id') ?                     params['imagen_id'].to_boolean :                     false,
      tipo_articulo_id:               validate_optional_param(params, 'tipo_articulo_id') ?              params['tipo_articulo_id'].to_boolean :              false,
      nombre:                         validate_optional_param(params, 'nombre') ?                        params['nombre'].to_boolean :                        false,
      costo_principal:                validate_optional_param(params, 'costo_principal') ?               params['costo_principal'].to_boolean :               false,
      precio_principal:               validate_optional_param(params, 'precio_principal') ?              params['precio_principal'].to_boolean :              false,
      existencia:                     validate_optional_param(params, 'existencia') ?                    params['existencia'].to_boolean :                    false,
      aviso_existencia:               validate_optional_param(params, 'aviso_existencia') ?              params['aviso_existencia'].to_boolean :              false,
      codigo:                         validate_optional_param(params, 'codigo') ?                        params['codigo'].to_boolean :                        false,
      fecha_ingreso:                  validate_optional_param(params, 'fecha_ingreso') ?                 params['fecha_ingreso'].to_boolean :                 false,
      medida:                         validate_optional_param(params, 'medida') ?                        params['medida'].to_boolean :                        false,
      is_detallable:                  validate_optional_param(params, 'is_detallable') ?                 params['is_detallable'].to_boolean :                 false,
      medida_alerta:                  validate_optional_param(params, 'medida_alerta') ?                 params['medida_alerta'].to_boolean :                 false,
      calcular_itbis:                 validate_optional_param(params, 'calcular_itbis') ?                params['calcular_itbis'].to_boolean :                false,
      estado:                         validate_optional_param(params, 'estado') ?                        params['estado'].to_boolean :                        false,
      is_combo:                       validate_optional_param(params, 'is_combo') ?                      params['is_combo'].to_boolean :                      false,
      otros_costos:                   validate_optional_param(params, 'otros_costos') ?                  params['otros_costos'].to_boolean :                  false,
      vendido_en:                     validate_optional_param(params, 'vendido_en') ?                    params['vendido_en'].to_boolean :                    false,
      is_materia_prima:               validate_optional_param(params, 'is_materia_prima') ?              params['is_materia_prima'].to_boolean :              false,
      contenido_articulos:            validate_optional_param(params, 'contenido_articulos') ?           params['contenido_articulos'].to_boolean :           false,
      formulas_productos_terminados:  validate_optional_param(params, 'formulas_productos_terminados') ? params['formulas_productos_terminados'].to_boolean : false,
      descripcion:                    validate_optional_param(params, 'descripcion') ?                   params['descripcion'].to_boolean :                   false,
      contenido:                      validate_optional_param(params, 'contenido') ?                     params['contenido'].to_boolean :                     false,
      cantidades:                     validate_optional_param(params, 'cantidades') ?                    params['cantidades'].to_boolean :                    false,
      calcular_saco:                  validate_optional_param(params, 'calcular_saco') ?                 params['calcular_saco'].to_boolean :                 false,
      costos:                         validate_optional_param(params, 'costos') ?                        params['costos'].to_boolean :                        false,
      tipo_articulo:                  validate_optional_param(params, 'tipo_articulo') ?                 params['tipo_articulo'].to_boolean :                 false,
    }
  end


  private

  # Use callbacks to share common setup or constraints between actions.
  def set_articulo
    respuesta = set_entidad(Articulo, params)
    @articulo = respuesta.get_data

    return respuesta.send_response self if @articulo.nil?
  end
end
