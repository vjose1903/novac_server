class DetalleFacturasController < ApplicationController
  before_action :set_detalle_factura, only: [:show, :update, :destroy]

  # GET /detalle_facturas
  def index
    @detalle_facturas = DetalleFactura.all

    render body: DetalleFacturaSerializer.collection_to_hash(@detalle_facturas).to_json, content_type: 'application/json'
  end

  # GET /detalle_facturas/1
  def show
    render body: DetalleFacturaSerializer.to_hash(@detalle_factura).to_json, content_type: 'application/json'
  end

  # POST /detalle_facturas
  def create
    @detalle_factura = DetalleFactura.new(params)

    if @detalle_factura.save
      render json: @detalle_factura, status: :created, location: @detalle_factura
    else
      render json: @detalle_factura.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /detalle_facturas/1
  def update
    if @detalle_factura.update(params)
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

end
