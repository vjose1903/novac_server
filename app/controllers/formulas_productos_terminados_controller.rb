class FormulasProductosTerminadosController < ApplicationController
  before_action :set_formulas_productos_terminado, only: [:show, :update, :destroy]

  # GET /formulas_productos_terminados
  def index
    @formulas_productos_terminados = FormulasProductosTerminado.all

    render json: @formulas_productos_terminados
  end

  # GET /formulas_productos_terminados/1
  def show
    render json: @formulas_productos_terminado
  end

  # POST /formulas_productos_terminados
  def create
    @formulas_productos_terminado = FormulasProductosTerminado.new(formulas_productos_terminado_params)

    if @formulas_productos_terminado.save
      render json: @formulas_productos_terminado, status: :created, location: @formulas_productos_terminado
    else
      render json: @formulas_productos_terminado.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /formulas_productos_terminados/1
  def update
    if @formulas_productos_terminado.update(formulas_productos_terminado_params)
      render json: @formulas_productos_terminado
    else
      render json: @formulas_productos_terminado.errors, status: :unprocessable_entity
    end
  end

  # DELETE /formulas_productos_terminados/1
  def destroy
    @formulas_productos_terminado.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_formulas_productos_terminado
    @formulas_productos_terminado = FormulasProductosTerminado.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def formulas_productos_terminado_params
    params.require(:formulas_productos_terminado).permit(:articulo_id, :cantidad, :costo, :_destroy, :articulo_combo)
  end
end
