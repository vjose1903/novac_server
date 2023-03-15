class CuentasContablesController < ApplicationController
  before_action :set_cuenta_contable, only: [ :show, :update, :destroy ]


  # GET /cuentas_contables
  def index
    cuentas = CuentaContable.all.where({ estado: true}).order('id ASC')
    return Response.new(params, nil, CatalogoCuenta::CuentaContable.iterator(cuentas), nil).send_response self
  end

  # GET /cuentas_contables/1
  def show
    return Response.new(params, nil, @cuenta_contable, nil, {all: true}).send_response self
  end

  def crear_actualizar_cuenta_contable
    res          = CuentaContable.create_update_cuenta_contable(params, nil, true)
    res.send_response self
  end

  # POST /cuentas_contables
  def create
    crear_actualizar_cuenta_contable
  end

  # PATCH/PUT /cuentas_contables/1
  def update
    crear_actualizar_cuenta_contable
  end

  # DELETE /cuentas_contables/1
  def destroy
    resultado = borrar_entidad(@cuenta_contable)
    resultado.send_response self
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cuenta_contable
      respuesta = set_entidad(CuentaContable, params)
      @cuenta_contable = respuesta.get_data

      return respuesta.send_response self if @cuenta_contable.nil?
  end
end
