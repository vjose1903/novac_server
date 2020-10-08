class DetallesProduccionController < ApplicationController
  before_action :set_detalle_produccion, only: [:show, :update, :destroy]

  # GET /detalles_produccion
  def index
    @detalles_produccion = DetalleProduccion.all

    render json: @detalles_produccion
  end

  # GET /detalles_produccion/1
  def show
    render json: @detalle_produccion
  end

  # POST /detalles_produccion
  def create
    @detalle_produccion = DetalleProduccion.new(detalle_produccion_params)

    if @detalle_produccion.save
      render json: @detalle_produccion, status: :created, location: @detalle_produccion
    else
      render json: @detalle_produccion.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /detalles_produccion/1
  def update
    if @detalle_produccion.update(detalle_produccion_params)
      render json: @detalle_produccion
    else
      render json: @detalle_produccion.errors, status: :unprocessable_entity
    end
  end

  # DELETE /detalles_produccion/1
  def destroy
    @detalle_produccion.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_detalle_produccion
      @detalle_produccion = DetalleProduccion.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def detalle_produccion_params
      params.require(:detalle_produccion).permit(:produccion_id, :articulo_id, :cantidad, :cantidad_en_unidades, :medida)
    end
end
