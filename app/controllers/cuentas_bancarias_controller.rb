class CuentasBancariasController < ApplicationController
  before_action :set_cuenta_bancaria, only: [ :show, :destroy ]

  # GET /cuentas_bancarias
  def index
    return Response.new(params, nil, CuentaBancaria.all.order('id ASC'), nil, { all: true }).send_response self
  end

  # GET /cuentas_bancarias/1
  def show
    return Response.new(params, nil, @cuenta_bancaria, nil, { all: true }).send_response self
  end

  def crear_actualizar_cuenta_bancaria
    resultado = CuentaBancaria.create_update_cuenta_bancaria(params, nil, true)
    resultado.send_response self
  end

  # POST /cuentas_bancarias
  def create
    crear_actualizar_cuenta_bancaria
  end

  # PATCH/PUT /cuentas_bancarias/1
  def update
    crear_actualizar_cuenta_bancaria
  end

  # DELETE /cuentas_bancarias/1
  def destroy
    resultado   = borrar_entidad(@cuenta_bancaria)
    actions     = resultado.get_data

    if actions[:disabled]
      resultado = borrar_entidad(@cuenta_bancaria.cuenta_contable)       unless @cuenta_bancaria.cuenta_contable.nil?
      resultado = borrar_entidad(@cuenta_bancaria.cuenta_contable_prima) unless @cuenta_bancaria.cuenta_contable_prima.nil?
    end

    resultado.send_response self
  end

  private

    def set_cuenta_bancaria
      respuesta = set_entidad(CuentaBancaria, params)
      @cuenta_bancaria  = respuesta.get_data

      return respuesta.send_response self if @cuenta_bancaria.nil?
    end
end
