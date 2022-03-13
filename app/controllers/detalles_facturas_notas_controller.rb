class DetallesFacturasNotasController < ApplicationController
  before_action :set_detalle_factura_nota, only: [:show, :update, :destroy]

  # GET /detalles_facturas_notas
  def index
    @detalles_facturas_notas = DetalleFacturaNota.all

    render json: @detalles_facturas_notas
  end

  # GET /detalles_facturas_notas/1
  def show
    render json: @detalle_factura_nota
  end

  # POST /detalles_facturas_notas
  def create
    @detalle_factura_nota = DetalleFacturaNota.new(detalle_factura_nota_params)

    if @detalle_factura_nota.save
      render json: @detalle_factura_nota, status: :created, location: @detalle_factura_nota
    else
      render json: @detalle_factura_nota.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /detalles_facturas_notas/1
  def update
    if @detalle_factura_nota.update(detalle_factura_nota_params)
      render json: @detalle_factura_nota
    else
      render json: @detalle_factura_nota.errors, status: :unprocessable_entity
    end
  end

  # DELETE /detalles_facturas_notas/1
  def destroy
    @detalle_factura_nota.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_detalle_factura_nota
      @detalle_factura_nota = DetalleFacturaNota.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def detalle_factura_nota_params
      params.require(:detalle_factura_nota).permit(:factura_aplicada_id, :articulo_id, :detalle_factura_id, :unidad, :cantidad, :cantidad_en_unidades, :itbis, :costo, :precio, :total, :descuento)
    end
end
