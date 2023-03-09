class DetallesPeriodosFiscalesController < ApplicationController
  before_action :set_detalle_periodo_fiscal, only: [ :show, :update, :destroy ]

  # GET /detalles_periodos_fiscales
  def index
    @detalles_periodos_fiscales = DetallePeriodoFiscal.all

    render json: @detalles_periodos_fiscales
  end

  # GET /detalles_periodos_fiscales/1
  def show
    render json: @detalle_periodo_fiscal
  end

  # POST /detalles_periodos_fiscales
  def create
    @detalle_periodo_fiscal = DetallePeriodoFiscal.new(detalle_periodo_fiscal_params)

    if @detalle_periodo_fiscal.save
      render json: @detalle_periodo_fiscal, status: :created, location: @detalle_periodo_fiscal
    else
      render json: @detalle_periodo_fiscal.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /detalles_periodos_fiscales/1
  def update
    if @detalle_periodo_fiscal.update(detalle_periodo_fiscal_params)
      render json: @detalle_periodo_fiscal
    else
      render json: @detalle_periodo_fiscal.errors, status: :unprocessable_entity
    end
  end

  # DELETE /detalles_periodos_fiscales/1
  def destroy
    @detalle_periodo_fiscal.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_detalle_periodo_fiscal
      @detalle_periodo_fiscal = DetallePeriodoFiscal.find(params[:id])
    end
end
