class CabeceraConducesController < ApplicationController
  before_action :set_cabecera_conduce, only: [:show, :update, :destroy]

  # GET /cabecera_conduces
  def index
    return Response.new(params, nil, CabeceraConduce.all.order('id DESC'), nil, get_parametros_opcionales).send_response self
  end

  # GET /cabecera_conduces/1
  def show
    return Response.new(params, nil, @cabecera_conduce, nil, get_parametros_opcionales).send_response self
  end

  def crear_actualizar_conduce
		parametros = params
		parametros["id"] = params["id"] if params["id"]

    resultado = CabeceraConduce.create_update_conduce(parametros, true)
		resultado.send_response self
	end

  # POST /cabecera_conduces
  def create
    crear_actualizar_conduce
  end

  # PATCH/PUT /cabecera_conduces/1
  def update
    crear_actualizar_articulo
  end

  # DELETE /cabecera_conduces/1
  def destroy
    resultado = borrar_entidad(@cabecera_conduce)
    resultado.send_response self
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_cabecera_conduce
    respuesta = set_entidad(CabeceraConduce, params)
    @cabecera_conduce = respuesta.get_data

    return respuesta.send_response self if @cabecera_conduce.nil?
  end


  def get_parametros_opcionales 
    return {
      all:                params['all'] || false,
      id:                 params['id'] || false,
      user_id:            params['user_id'] || false,
      cliente_id:         params['cliente_id'] || false,
      numero_conduce:     params['numero_conduce'] || false,
      fecha_equivalente:  params['fecha_equivalente'] || false,
      cliente:            params['cliente'] || false,
      detalle_conduces:   params['detalle_conduces'] || false,
    }
  end

end
