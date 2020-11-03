class IncidenciasController < ApplicationController
  before_action :set_incidencia, only: [:show, :update, :destroy]

  # GET /incidencias
  def index
    @incidencias = Incidencia.all

    render json: @incidencias
  end

  # GET /incidencias/1
  def show
    render json: @incidencia
  end

  # POST /incidencias
  def create
    @incidencia = Incidencia.new(incidencia_params)

    if @incidencia.save
      render json: @incidencia, status: :created, location: @incidencia
    else
      render json: @incidencia.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /incidencias/1
  def update
    if @incidencia.update(incidencia_params)
      render json: @incidencia
    else
      render json: @incidencia.errors, status: :unprocessable_entity
    end
  end

  # DELETE /incidencias/1
  def destroy
    @incidencia.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_incidencia
      @incidencia = Incidencia.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def incidencia_params
      params.require(:incidencia).permit(:referencia, :descripcion)
    end
end
