class CierreCuentasController < ApplicationController
  before_action :set_cierre_cuenta, only:[ :show, :destroy ]

  # GET /cierre_cuentas
  def index
    @cierre_cuentas = CierreCuenta.all

    render json: @cierre_cuentas
  end

  # GET /cierre_cuentas/1
  def show
    render json: @cierre_cuenta
  end

  # POST /cierre_cuentas
  def create
    @cierre_cuenta = CierreCuenta.new(cierre_cuenta_params)

    if @cierre_cuenta.save
      render json: @cierre_cuenta, status: :created, location: @cierre_cuenta
    else
      render json: @cierre_cuenta.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /cierre_cuentas/1
  def update
    if @cierre_cuenta.update(cierre_cuenta_params)
      render json: @cierre_cuenta
    else
      render json: @cierre_cuenta.errors, status: :unprocessable_entity
    end
  end

  # DELETE /cierre_cuentas/1
  def destroy
    @cierre_cuenta.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cierre_cuenta
      respuesta = set_entidad(CierreCuenta, params)
      @cierre_cuenta = respuesta.get_data

      return respuesta.send_response self if @cierre_cuenta.nil?
  end
end
