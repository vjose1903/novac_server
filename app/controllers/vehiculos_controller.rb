class VehiculosController < ApplicationController
  before_action :set_vehiculo, only: [:show, :update, :destroy]

  # GET /vehiculos
  def index
    return Response.new(params, nil, Vehiculo.all.where({ estado: true}).order('id DESC'), nil, get_parametros_opcionales, Vehiculo.models_includes).send_response self
  end


  # GET /vehiculos/1
  def show
    return Response.new(params, nil, @vehiculo, nil, get_parametros_opcionales).send_response self
  end


  def getVehiculosFiltrados
    arg = params["arg"]
    resultado = Vehiculo.filtrarVehiculo(arg, set_paginate_options(params), get_parametros_opcionales)
    resultado.send_response self
  end

  def crear_actualizar_vehiculo
    resultado = Vehiculo.crear_actualizar_vehiculo(params, true)
    resultado.send_response self
  end

  # POST /vehiculos
  def create
    crear_actualizar_vehiculo
  end


  # PATCH/PUT /vehiculos/1
  def update
    crear_actualizar_vehiculo
  end

  def destroy
    resultado = borrar_entidad(@vehiculo)
    resultado.send_response self
  end

  def get_parametros_opcionales
    return {
      all:                          true,
      info_vehiculo:                validate_optional_param(params, 'info_vehiculo') ?               params['info_vehiculo'].to_boolean :               false,
      nombre_completo_propietario:  validate_optional_param(params, 'nombre_completo_propietario') ? params['nombre_completo_propietario'].to_boolean : false,
    }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vehiculo
      respuesta = set_entidad(Vehiculo, params)
      @vehiculo = respuesta.get_data

      return respuesta.send_response self if @vehiculo.nil?
    end
end
