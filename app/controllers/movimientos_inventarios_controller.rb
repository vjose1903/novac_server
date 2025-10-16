class MovimientosInventariosController < ApplicationController
  before_action :set_movimientos_inventario, only: [:show, :update, :destroy]

  # GET /movimientos_inventarios
  def index
    @movimientos_inventarios = MovimientosInventario.all

    render json: @movimientos_inventarios
  end

  # GET /movimientos_inventarios/1
  def show
    render json: @movimientos_inventario
  end

  # POST /movimientos_inventarios
	def create
    resultado = MovimientosInventario.movimientos_de_inventario(params, OperadoresMovimiento.return_operador(params["accion"]), DateTime.now.strftime("%d/%m/%Y"), 'movimiento', nil)
		resultado.send_response self
	end

  # DELETE /movimientos_inventarios/1
  def destroy
    @movimientos_inventario.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_movimientos_inventario
    @movimientos_inventario = MovimientosInventario.find(params[:id])
  end
end
