class SecuenciaIngresosController < ApplicationController
  before_action :set_secuencia_ingreso, only: [:show, :update, :destroy]

  # GET /secuencia_ingresos
  def index
    @secuencia_ingresos = SecuenciaIngreso.all

    render json: @secuencia_ingresos
  end

  # GET /secuencia_ingresos/1
  def show
    render json: @secuencia_ingreso
  end

  # POST /secuencia_ingresos
  def create
    @secuencia_ingreso = SecuenciaIngreso.new(secuencia_ingreso_params)

    if @secuencia_ingreso.save
      render json: @secuencia_ingreso, status: :created, location: @secuencia_ingreso
    else
      render json: @secuencia_ingreso.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /secuencia_ingresos/1
  def update
    if @secuencia_ingreso.update(secuencia_ingreso_params)
      render json: @secuencia_ingreso
    else
      render json: @secuencia_ingreso.errors, status: :unprocessable_entity
    end
  end

  # DELETE /secuencia_ingresos/1
  def destroy
    @secuencia_ingreso.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_secuencia_ingreso
      @secuencia_ingreso = SecuenciaIngreso.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def secuencia_ingreso_params
      params.require(:secuencia_ingreso).permit(:tipo_recibo_id, :secuencia)
    end
end
