class CabeceraConducesController < ApplicationController
  before_action :set_cabecera_conduce, only: [:show, :update, :destroy]

  # GET /cabecera_conduces
  def index
    @cabecera_conduces = CabeceraConduce.all

    render json: @cabecera_conduces
  end

  # GET /cabecera_conduces/1
  def show
    render json: @cabecera_conduce
  end

  # POST /cabecera_conduces
  def create
    @cabecera_conduce = CabeceraConduce.new(cabecera_conduce_params)

    if @cabecera_conduce.save
      render json: @cabecera_conduce, status: :created, location: @cabecera_conduce
    else
      render json: @cabecera_conduce.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /cabecera_conduces/1
  def update
    if @cabecera_conduce.update(cabecera_conduce_params)
      render json: @cabecera_conduce
    else
      render json: @cabecera_conduce.errors, status: :unprocessable_entity
    end
  end

  # DELETE /cabecera_conduces/1
  def destroy
    @cabecera_conduce.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_cabecera_conduce
    @cabecera_conduce = CabeceraConduce.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def cabecera_conduce_params
    params.require(:cabecera_conduce).permit(:user_id, :cliente_id, :numero_conduce,
                                             detalle_conduce_attributes: [:cabecera_conduce_id, :detalle_factura_id, :articulo_id, :cantidad, :unidad])
  end
end
