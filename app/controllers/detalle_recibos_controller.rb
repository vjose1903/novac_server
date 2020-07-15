class DetalleRecibosController < ApplicationController
  before_action :set_detalle_recibo, only: [:show, :update, :destroy]

  # GET /detalle_recibos
  def index
    @detalle_recibos = DetalleRecibo.all

    render json: @detalle_recibos
  end

  # GET /detalle_recibos/1
  def show
    render json: @detalle_recibo
  end

  # POST /detalle_recibos
  def create
    @detalle_recibo = DetalleRecibo.new(detalle_recibo_params)

    if @detalle_recibo.save
      render json: @detalle_recibo, status: :created, location: @detalle_recibo
    else
      render json: @detalle_recibo.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /detalle_recibos/1
  def update
    if @detalle_recibo.update(detalle_recibo_params)
      render json: @detalle_recibo
    else
      render json: @detalle_recibo.errors, status: :unprocessable_entity
    end
  end

  # DELETE /detalle_recibos/1
  def destroy
    @detalle_recibo.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_detalle_recibo
      @detalle_recibo = DetalleRecibo.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def detalle_recibo_params
      params.require(:detalle_recibo).permit(:cabecera_recibo_id, :trabajo_id, :cabecera_factura_id, :total, :descripcion, :deposito)
    end
end
