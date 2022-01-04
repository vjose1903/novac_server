class ProduccionesController < ApplicationController
  before_action :set_produccion, only: [:show, :update, :destroy]

  # GET /producciones
  def index
    return Response.new(params, nil, Produccion.all, nil, {all: true}).send_response self
  end
  
  # GET /producciones/1
  def show
    return Response.new(params, nil, @produccion, nil, {all: true}).send_response self
  end

  def getProduccionesFiltradas
    arg = params["arg"]
    resultado = Produccion.filtrarProduccion(arg, set_paginate_options(params))
    resultado.send_response self
  end


  def crear_actualizar_produccion
		parametros = params
		parametros["id"] = params["id"] if params["id"]

    resultado = Produccion.create_update_produccion(parametros, true)
		resultado.send_response self
	end

  # POST /producciones
  def create
    crear_actualizar_produccion
  end

  # PATCH/PUT /producciones/1
  def update
    crear_actualizar_produccion
  end

  # DELETE /producciones/1
  def destroy
    resultado = borrar_entidad(@produccion)
    resultado.send_response self
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_produccion
    respuesta   = set_entidad(Produccion, params)
    @produccion = respuesta.get_data
      
    return respuesta.send_response self if @produccion.nil?
  end
end
