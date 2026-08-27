class SuplidoresController < ApplicationController
  before_action :set_suplidor, only: [:show, :destroy]

  # GET /suplidores
  def index    
    resultado = Suplidor.serialized_response(Suplidor.where({ estado: true}).order('id DESC'), params, {all: true})
    render_json_response(resultado)
  end

  # GET /suplidores/1
  def show
    ActiveRecord::Associations::Preloader.new(records: [@suplidor], associations: Suplidor.models_includes).call
    resultado = {status: HTTP_STATUS_CODE[:ok], data: SuplidorSerializer.to_hash(@suplidor, {all: true}), msg: nil}
    render_json_response(resultado)
  end 

  def getNombresSuplidores
    resultado = Suplidor.serialized_response(Suplidor.where({ estado: true}).order('id DESC'), params, {id: true, nombre: true})
    render_json_response(resultado)
  end

  def getSuplidoresFiltrados
    arg = params["arg"]
    resultado = Suplidor.filtrarSuplidores(arg, set_paginate_options(params).merge("order_by" => params[:order_by]))
    render_json_response(resultado)
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

  def render_json_response(resultado)
    render body: resultado.except(:status).to_json, status: resultado[:status], content_type: 'application/json'
  end
end
