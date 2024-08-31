class VehiculosController < ApplicationController
  before_action :set_vehiculo, only: [:show, :update, :destroy]

  # GET /vehiculos
  def index
    puts "get_parametros_opcionales ===> ".red + " #{get_parametros_opcionales}"
    return Response.new(params, nil, Vehiculo.all.where({ estado: true}).order('id DESC'), nil, get_parametros_opcionales).send_response self
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

  # POST /vehiculos
  def create

    @vehiculo = Vehiculo.new(vehiculo_params)
    @vehiculo.cantidad_viajes =0

    if @vehiculo.save
      render json: @vehiculo, status: :created, location: @vehiculo
    else
      render json: @vehiculo.errors, status: :unprocessable_entity
    end
  end


  # PATCH/PUT /vehiculos/1
  def update
    if @vehiculo.update(vehiculo_params)
      render json: @vehiculo
    else
      render json: @vehiculo.errors, status: :unprocessable_entity
    end
  end

  def destroy
    is_deleted = @vehiculo.update({estado: false})

    render json: { msg: is_deleted ? "Vehiculo borrado" : "error borrando vehiculo." }
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
      @vehiculo = Vehiculo.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def vehiculo_params
      params.require(:vehiculo).permit(:user_id, :marca, :modelo, :anio, :estado, :cantidad_viajes, :nombre_no_empleado, :apellido_no_empleado, :telefono_no_empleado
      )
    end
end
