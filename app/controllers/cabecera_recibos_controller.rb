class CabeceraRecibosController < ApplicationController
  before_action :set_cabecera_recibo, only: [:show, :update, :destroy]

  # GET /cabecera_recibos
  def index
    @cabecera_recibos = CabeceraRecibo.all

    render json: @cabecera_recibos
  end

  # GET /cabecera_recibos/1
  def show
    render json: @cabecera_recibo
  end

  # POST /cabecera_recibos
  def create
    @cabecera_recibo = CabeceraRecibo.new(cabecera_recibo_params)

    if @cabecera_recibo.save
      render json: @cabecera_recibo, status: :created, location: @cabecera_recibo
    else
      render json: @cabecera_recibo.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /cabecera_recibos/1
  def update
    if @cabecera_recibo.update(cabecera_recibo_params)
      render json: @cabecera_recibo
    else
      render json: @cabecera_recibo.errors, status: :unprocessable_entity
    end
  end

  # DELETE /cabecera_recibos/1
  def destroy
    @cabecera_recibo.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cabecera_recibo
      @cabecera_recibo = CabeceraRecibo.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def cabecera_recibo_params
      params.require(:cabecera_recibo).permit(:user_id, :cliente_id, :forma_pago, :numero_recibo, :total, :devuelta)
    end
end
