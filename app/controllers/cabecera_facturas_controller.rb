class CabeceraFacturasController < ApplicationController
  before_action :set_cabecera_factura, only: [:show, :update, :destroy]

  # GET /cabecera_facturas
  def index
    @cabecera_facturas = CabeceraFactura.all

    render json: @cabecera_facturas
  end

  # GET /cabecera_facturas/1
  def show
    render json: @cabecera_factura
  end

  # POST /cabecera_facturas
  def create
    @cabecera_factura = CabeceraFactura.new(cabecera_factura_params)

    if @cabecera_factura.save
      render json: @cabecera_factura, status: :created, location: @cabecera_factura
    else
      render json: @cabecera_factura.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /cabecera_facturas/1
  def update
    if @cabecera_factura.update(cabecera_factura_params)
      render json: @cabecera_factura
    else
      render json: @cabecera_factura.errors, status: :unprocessable_entity
    end
  end

  # DELETE /cabecera_facturas/1
  def destroy
    @cabecera_factura.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cabecera_factura
      @cabecera_factura = CabeceraFactura.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def cabecera_factura_params
      params.require(:cabecera_factura).permit(:user_id, :cliente_id, :forma_pago, :numero_factura, :total_factura, :pagada, :balance, :tiene_nota, :devuelta, :noCliente_nombre, :noCliente_direccion)
    end
end
