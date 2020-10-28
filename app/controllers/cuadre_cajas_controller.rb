class CuadreCajasController < ApplicationController
  before_action :set_cuadre_caja, only: [:show, :update, :destroy]

  # GET /cuadre_cajas
  def index
    # @cuadre_cajas = CuadreCaja.all

    # render json: @cuadre_cajas

    cuadre_caja = CuadreCaja.makecuadre(current_user)

    render json: cuadre_caja, status: cuadre_caja[:status]
  end

  # GET /cuadre_cajas/1
  def show
    render json: @cuadre_caja
  end

  # POST /cuadre_cajas
  def create
    @cuadre_caja = CuadreCaja.new(cuadre_caja_params)

    if @cuadre_caja.save
      render json: @cuadre_caja, status: :created, location: @cuadre_caja
    else
      render json: @cuadre_caja.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /cuadre_cajas/1
  def update
    if @cuadre_caja.update(cuadre_caja_params)
      render json: @cuadre_caja
    else
      render json: @cuadre_caja.errors, status: :unprocessable_entity
    end
  end

  # DELETE /cuadre_cajas/1
  def destroy
    @cuadre_caja.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_cuadre_caja
    @cuadre_caja = CuadreCaja.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def cuadre_caja_params
    params.require(:cuadre_caja).permit(:user_id, :total_general, :total_venta_credito, :total_venta_contado, :total_recibo_ingreso, :total_anterior)
  end
end
