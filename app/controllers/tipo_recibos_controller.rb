class TipoRecibosController < ApplicationController
  before_action :set_tipo_recibo, only: [:show, :update, :destroy]

  # GET /tipo_recibos
  def index
    @tipo_recibos = TipoRecibo.all

    render json: @tipo_recibos
  end

  # GET /tipo_recibos/1
  def show
    render json: @tipo_recibo
  end

  # POST /tipo_recibos
  def create
    @tipo_recibo = TipoRecibo.new(tipo_recibo_params)

    if @tipo_recibo.save
      render json: @tipo_recibo, status: :created, location: @tipo_recibo
    else
      render json: @tipo_recibo.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /tipo_recibos/1
  def update
    if @tipo_recibo.update(tipo_recibo_params)
      render json: @tipo_recibo
    else
      render json: @tipo_recibo.errors, status: :unprocessable_entity
    end
  end

  # DELETE /tipo_recibos/1
  def destroy
    @tipo_recibo.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_tipo_recibo
    @tipo_recibo = TipoRecibo.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def tipo_recibo_params
    params.fetch(:tipo_recibo).permit(:descripcion)
  end
end
