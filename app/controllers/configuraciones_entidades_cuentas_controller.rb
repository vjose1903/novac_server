class ConfiguracionesEntidadesCuentasController < ApplicationController
  before_action :set_configuracion_entidad_cuenta, only: [:show, :update]

  # GET /configuraciones_entidades_cuentas
  def index
    return Response.new(params, nil, ConfiguracionEntidadCuenta.all.order('id DESC'), nil, {all: true}).send_response self
  end

  # GET /configuraciones_entidades_cuentas/1
  def show
    return Response.new(params, nil, @configuracion_entidad_cuenta, nil, {all: true}).send_response self
  end


  def actualizar_configuracion_entidad_cuenta
    resultado = ConfiguracionEntidadCuenta.update_configuracion_entidad_cuenta(params, @configuracion_entidad_cuenta,true)
    resultado.send_response self
  end

  # PATCH/PUT /configuraciones_entidades_cuentas/1
  def update
    actualizar_configuracion_entidad_cuenta
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_configuracion_entidad_cuenta
      respuesta = set_entidad(ConfiguracionEntidadCuenta, params)
      @configuracion_entidad_cuenta = respuesta.get_data

      return respuesta.send_response self if @configuracion_entidad_cuenta.nil?
    end

end