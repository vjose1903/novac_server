class DetalleConducesController < ApplicationController
  before_action :set_detalle_conduce, only: [:show, :update, :destroy]

  # GET /detalle_conduces
  def index
    @detalle_conduces = DetalleConduce.all
    render json: @detalle_conduces
  end

  # GET /detalle_conduces/1
  def show
    render json: @detalle_conduce
  end

  # POST /detalle_conduces
  def create
    @detalle_conduce = DetalleConduce.new(detalle_conduce_params)

    if @detalle_conduce.save
      render json: @detalle_conduce, status: :created, location: @detalle_conduce
    else
      render json: @detalle_conduce.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /detalle_conduces/1
  def update
    if @detalle_conduce.update(detalle_conduce_params)
      render json: @detalle_conduce
    else
      render json: @detalle_conduce.errors, status: :unprocessable_entity
    end
  end

  # DELETE /detalle_conduces/1
  def destroy
    @detalle_conduce.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_detalle_conduce
    @detalle_conduce = DetalleConduce.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def detalle_conduce_params
    params.require(:detalle_conduce).permit(:cabecera_conduce_id, :detalle_factura_id, :articulo_id, :cantidad, :unidad)
  end
end
