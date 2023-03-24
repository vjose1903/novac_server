class CuentasBancariasController < ApplicationController
  before_action :set_cuenta_bancaria, only: %i[ show update destroy ]

  # GET /cuentas_bancarias
  def index
    @cuentas_bancarias = CuentaBancaria.all

    render json: @cuentas_bancarias
  end

  # GET /cuentas_bancarias/1
  def show
    render json: @cuenta_bancaria
  end

  # POST /cuentas_bancarias
  def create
    @cuenta_bancaria = CuentaBancaria.new(cuenta_bancaria_params)

    if @cuenta_bancaria.save
      render json: @cuenta_bancaria, status: :created, location: @cuenta_bancaria
    else
      render json: @cuenta_bancaria.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /cuentas_bancarias/1
  def update
    if @cuenta_bancaria.update(cuenta_bancaria_params)
      render json: @cuenta_bancaria
    else
      render json: @cuenta_bancaria.errors, status: :unprocessable_entity
    end
  end

  # DELETE /cuentas_bancarias/1
  def destroy
    @cuenta_bancaria.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cuenta_bancaria
      @cuenta_bancaria = CuentaBancaria.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def cuenta_bancaria_params
      params.require(:cuenta_bancaria).permit(:banco_id, :tipo_cuenta_bancaria_id, :divisa_id, :cuenta_contable_id, :numero_cuenta, :comentario, :descripcion, :fecha_apertura, :is_nacional, :estado)
    end
end
