class TipoFacturasController < ApplicationController
  before_action :set_tipo_factura, only: [:show, :update, :destroy]

  # GET /tipo_facturas
  def index
    @tipo_facturas = TipoFactura.all

    render body: TipoFacturaSerializer.collection_to_hash(@tipo_facturas).to_json, content_type: 'application/json'
  end

  # GET /tipo_facturas/1
  def show
    render body: TipoFacturaSerializer.to_hash(@tipo_factura).to_json, content_type: 'application/json'
  end

  # POST /tipo_facturas
  def create
    @tipo_factura = TipoFactura.new(tipo_factura_params)

    if @tipo_factura.save
      render json: @tipo_factura, status: :created, location: @tipo_factura
    else
      render json: @tipo_factura.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /tipo_facturas/1
  def update
    if @tipo_factura.update(tipo_factura_params)
      render json: @tipo_factura
    else
      render json: @tipo_factura.errors, status: :unprocessable_entity
    end
  end

  # DELETE /tipo_facturas/1
  def destroy
    @tipo_factura.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tipo_factura
      @tipo_factura = TipoFactura.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def tipo_factura_params
      params.require(:tipo_factura).permit(:referencia, :descripcion)
    end
end
