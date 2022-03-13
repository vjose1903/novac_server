class FacturasAplicadasController < ApplicationController
  before_action :set_factura_aplicada, only: [:show, :update, :destroy]

  # GET /facturas_aplicadas
  def index
    @facturas_aplicadas = FacturaAplicada.all

    render json: @facturas_aplicadas
  end

  # GET /facturas_aplicadas/1
  def show
    render json: @factura_aplicada
  end

  # POST /facturas_aplicadas
  def create
    @factura_aplicada = FacturaAplicada.new(factura_aplicada_params)

    if @factura_aplicada.save
      render json: @factura_aplicada, status: :created, location: @factura_aplicada
    else
      render json: @factura_aplicada.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /facturas_aplicadas/1
  def update
    if @factura_aplicada.update(factura_aplicada_params)
      render json: @factura_aplicada
    else
      render json: @factura_aplicada.errors, status: :unprocessable_entity
    end
  end

  # DELETE /facturas_aplicadas/1
  def destroy
    @factura_aplicada.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_factura_aplicada
      @factura_aplicada = FacturaAplicada.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def factura_aplicada_params
      params.require(:factura_aplicada).permit(:nota_id, :cabeza_factura_id, :total)
    end
end
