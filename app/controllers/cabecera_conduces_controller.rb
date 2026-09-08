class CabeceraConducesController < ApplicationController
  before_action :set_cabecera_conduce, only: [:show, :update, :destroy, :revertirConduce]

  # GET /cabecera_conduces
  def index
    optional_params = get_parametros_opcionales
    return Response.new(params, nil, CabeceraConduce.all.order('id DESC'), nil, optional_params, CabeceraConduce.models_includes_for(optional_params)).send_response self
  end

  # GET /cabecera_conduces/1
  def show
    optional_params = get_parametros_opcionales
    return Response.new(params, nil, @cabecera_conduce, nil, optional_params, CabeceraConduce.models_includes_for(optional_params)).send_response self
  end

  def getConducesFiltrados
    arg = params["arg"]
    resultado = CabeceraConduce.filtrarConduces(arg, set_paginate_options(params))
    resultado.send_response self
  end

  def revertirConduce
    resultado = CabeceraConduce.revertir(@cabecera_conduce)
    resultado.send_response self
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
      all:               validate_optional_param(params, 'all') ?               params['all'].to_boolean :               false,
      id:                validate_optional_param(params, 'id') ?                params['id'].to_boolean :                false,
      user_id:           validate_optional_param(params, 'user_id') ?           params['user_id'].to_boolean :           false,
      cliente_id:        validate_optional_param(params, 'cliente_id') ?        params['cliente_id'].to_boolean :        false,
      numero_conduce:    validate_optional_param(params, 'numero_conduce') ?    params['numero_conduce'].to_boolean :    false,
      fecha_equivalente: validate_optional_param(params, 'fecha_equivalente') ? params['fecha_equivalente'].to_boolean : false,
      cliente:           validate_optional_param(params, 'cliente') ?           params['cliente'].to_boolean :           false,
      detalle_conduces:  validate_optional_param(params, 'detalle_conduces') ?  params['detalle_conduces'].to_boolean :  false,
    }
  end

end
