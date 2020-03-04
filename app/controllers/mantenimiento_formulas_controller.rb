class MantenimientoFormulasController < ApplicationController
  before_action :set_mantenimiento_formula, only: [:show, :update, :destroy]

  # GET /mantenimiento_formulas
  def index
    @mantenimiento_formulas = MantenimientoFormula.all

    render json: @mantenimiento_formulas
  end

  # GET /mantenimiento_formulas/1
  def show
    render json: @mantenimiento_formula
  end

  # POST /mantenimiento_formulas
  def create
    @mantenimiento_formula = MantenimientoFormula.new(mantenimiento_formula_params)

    if @mantenimiento_formula.save
      render json: @mantenimiento_formula, status: :created, location: @mantenimiento_formula
    else
      render json: @mantenimiento_formula.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /mantenimiento_formulas/1
  def update
    if @mantenimiento_formula.update(mantenimiento_formula_params)
      render json: @mantenimiento_formula
    else
      render json: @mantenimiento_formula.errors, status: :unprocessable_entity
    end
  end

  # DELETE /mantenimiento_formulas/1
  def destroy
    @mantenimiento_formula.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_mantenimiento_formula
    @mantenimiento_formula = MantenimientoFormula.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def mantenimiento_formula_params
    params.require(:mantenimiento_formula).permit(:mantenimiento_articulos_id, :articulo_id, :cantidad, :secuencia, :_destroy)
  end
end
