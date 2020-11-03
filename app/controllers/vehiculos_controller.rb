class VehiculosController < ApplicationController
  before_action :set_vehiculo, only: [:show, :update, :destroy]

  # GET /vehiculos
  def index
    @vehiculos = Vehiculo.all

    render json: @vehiculos
  end

  # GET /vehiculos/1
  def show
    render json: @vehiculo
  end

  # POST /vehiculos
  def create
    @vehiculo = Vehiculo.new(vehiculo_params)

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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vehiculo
      @vehiculo = Vehiculo.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def vehiculo_params
      params.require(:vehiculo).permit(:user_id, :marca, :modelo, :cantidad_viajes)
    end
end
