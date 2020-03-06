class SecuenciaFacturasController < ApplicationController
  before_action :set_secuencia_factura, only: [:show, :update, :destroy]

  # GET /secuencia_facturas
  def index
    @secuencia_facturas = SecuenciaFactura.all

    render json: @secuencia_facturas
  end

  # GET /secuencia_facturas/1
  def show
    render json: @secuencia_factura
  end

  # POST /secuencia_facturas
  def create
    @secuencia_factura = SecuenciaFactura.new(secuencia_factura_params)

    if @secuencia_factura.save
      render json: @secuencia_factura, status: :created, location: @secuencia_factura
    else
      render json: @secuencia_factura.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /secuencia_facturas/1
  def update
    if @secuencia_factura.update(secuencia_factura_params)
      render json: @secuencia_factura
    else
      render json: @secuencia_factura.errors, status: :unprocessable_entity
    end
  end

  # DELETE /secuencia_facturas/1
  def destroy
    @secuencia_factura.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_secuencia_factura
      @secuencia_factura = SecuenciaFactura.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def secuencia_factura_params
      params.fetch(:secuencia_factura).permit(:tipo_factura_id, :secuencia)
    end
end
