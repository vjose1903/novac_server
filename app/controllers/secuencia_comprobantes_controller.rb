class SecuenciaComprobantesController < ApplicationController
  before_action :set_secuencia_comprobante, only: [:show, :update, :destroy]

  # GET /secuencia_comprobantes
  def index
    @secuencia_comprobantes = SecuenciaComprobante.all

    render json: @secuencia_comprobantes
  end

  # GET /secuencia_comprobantes/1
  def show
    render json: @secuencia_comprobante
  end

  # POST /secuencia_comprobantes
  def create
    @secuencia_comprobante = SecuenciaComprobante.new(secuencia_comprobante_params)

    if @secuencia_comprobante.save
      render json: @secuencia_comprobante, status: :created, location: @secuencia_comprobante
    else
      render json: @secuencia_comprobante.errors, status: :unprocessable_entity
    end
  end
  
  
  def getPaqueteRncByEstado
    paquete = SecuenciaComprobante.get_paquete_rnc_by_estado(params[:id],params[:estado])
    render json: paquete, status: paquete[:status]
  end


  # PATCH/PUT /secuencia_comprobantes/1
  def update
    if @secuencia_comprobante.update(secuencia_comprobante_params)
      render json: @secuencia_comprobante
    else
      render json: @secuencia_comprobante.errors, status: :unprocessable_entity
    end
  end

  # DELETE /secuencia_comprobantes/1
  def destroy
    @secuencia_comprobante.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_secuencia_comprobante
      @secuencia_comprobante = SecuenciaComprobante.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def secuencia_comprobante_params
      params.fetch(:secuencia_comprobante).permit(:tipo_factura_id, :secuencia, :desde, :hasta, :fecha_compra, :fecha_valida, :estado)
    end
end
