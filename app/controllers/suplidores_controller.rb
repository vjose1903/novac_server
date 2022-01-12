class SuplidoresController < ApplicationController
  before_action :set_suplidor, only: [:show, :destroy]

  # GET /suplidores
  def index    
    return Response.new(params, nil, Suplidor.all.where({ estado: true}).order('id DESC'), nil, {all: true}).send_response self
  end

  # GET /suplidores/1
  def show
    return Response.new(params, nil, @suplidor, nil, {all: true}).send_response self
  end 

  def getNombresSuplidores
    return Response.new(params, nil, Suplidor.all.where({ estado: true}).order('id DESC'), nil, {id: true, nombre: true}).send_response self
  end

  def getSuplidoresFiltrados
    arg = params["arg"]
    resultado = Suplidor.filtrarSuplidores(arg, set_paginate_options(params))
    resultado.send_response self
  end

  def crear_actualizar_suplidor
		parametros = params
		parametros["id"] = params["id"] if params["id"]

    resultado = Suplidor.create_update_suplidor(parametros, true)
		resultado.send_response self
	end

  # POST /suplidores
  def create
    crear_actualizar_suplidor
  end

  # PATCH/PUT /suplidores/1
  def update
    crear_actualizar_suplidor
  end

  # DELETE /suplidores/1
  def destroy
    resultado = borrar_entidad(@suplidor)
    resultado.send_response self
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_suplidor
    
    params[:id] = params[:suplidor_id] if params[:suplidor_id] 
    respuesta = set_entidad(Suplidor, params)
    @suplidor = respuesta.get_data
    
    return respuesta.send_response self if @suplidor.nil?
  end
end
