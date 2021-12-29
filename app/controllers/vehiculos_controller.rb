class VehiculosController < ApplicationController
  before_action :set_vehiculo, only: [:show, :update, :destroy]

  # GET /vehiculos
  def index
    vehiculos = []
    @vehiculos = Vehiculo.all
    @vehiculos.each do |item|
      if item.estado
        vehiculos.push(item)
      end
    end

    render json: vehiculos
  end

  # GET /vehiculos/1
  def show
    render json: @vehiculo
  end

  
  def getVehiculosFiltrados
    arg = params["arg"]
    resultado = Vehiculo.filtrarVehiculo(arg, set_paginate_options(params))
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

  # DELETE /vehiculos/1
  def destroy
    @vehiculo.destroy
  end

  def deleteVehiculo
    vehiculo = Vehiculo.find_by_id(params[:id])

    if vehiculo.update({estado: false})
      render json: { msg: "Vehiculo borrado" }
    else
      render json: { msg: "error borrando vehiculo." }
    end
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
