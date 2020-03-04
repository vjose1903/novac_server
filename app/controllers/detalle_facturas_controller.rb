class DetalleFacturasController < ApplicationController
  before_action :set_detalle_factura, only: [:show, :update, :destroy]

  # GET /detalle_facturas
  def index
    @detalle_facturas = DetalleFactura.all

    render json: @detalle_facturas
  end

  # GET /detalle_facturas/1
  def show
    render json: @detalle_factura
  end

  # POST /detalle_facturas
  def create
    @detalle_factura = DetalleFactura.new(detalle_factura_params)

    if @detalle_factura.save
      render json: @detalle_factura, status: :created, location: @detalle_factura
    else
      render json: @detalle_factura.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /detalle_facturas/1
  def update
    if @detalle_factura.update(detalle_factura_params)
      render json: @detalle_factura
    else
      render json: @detalle_factura.errors, status: :unprocessable_entity
    end
  end

  # DELETE /detalle_facturas/1
  def destroy
    @detalle_factura.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_detalle_factura
    @detalle_factura = DetalleFactura.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def detalle_factura_params
    params.require(:detalle_factura).permit(:cabecera_factura_id, :articulo_id, :cantidad, :total, :unidad, :descuento_valor,:descuento_porciento, :itbis, :precio)
  end
end
