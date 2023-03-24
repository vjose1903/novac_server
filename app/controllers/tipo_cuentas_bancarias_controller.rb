class TipoCuentasBancariasController < ApplicationController
  before_action :set_tipo_cuenta_bancaria, only: [ :show, :destroy ]

  # GET /tipo_cuentas_bancarias
  def index
    return Response.new(params, nil, TipoCuentaBancaria.all.where({ estado: true }).order('id ASC'), nil, { all: true }).send_response self
  end

  # GET /tipo_cuentas_bancarias/1
  def show
    return Response.new(params, nil, @tipo_cuenta_bancaria, nil, { all: true }).send_response self
  end

  def crear_actualizar_tipo_cuenta
    resultado = TipoCuentaBancaria.create_update_tipo_cuenta(params, true)
    resultado.send_response self
  end

  # POST /tipo_cuentas_bancarias
  def create
    crear_actualizar_tipo_cuenta
  end

  # PATCH/PUT /tipo_cuentas_bancarias/1
  def update
    crear_actualizar_tipo_cuenta
  end

  # DELETE /tipo_cuentas_bancarias/1
  def destroy
    resultado = borrar_entidad(@tipo_cuenta_bancaria)
    resultado.send_response self
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tipo_cuenta_bancaria
      respuesta = set_entidad(TipoCuentaBancaria, params)
      @tipo_cuenta_bancaria  = respuesta.get_data

      return respuesta.send_response self if @tipo_cuenta_bancaria.nil?
    end

end
