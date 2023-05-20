class ConfiguracionesEntidadesCuentasController < ApplicationController
  before_action :set_configuracion_entidad_cuenta, only: [:show, :update]

  # GET /configuraciones_entidades_cuentas
  def index

    if has_filter_target(params)
      resultado      = ConfiguracionEntidadCuenta.filtrar(params, get_parametros_opcionales)
      resultado.send_response self
    else
      return Response.new(params, nil, ConfiguracionEntidadCuenta.all.order('id DESC').includes(ConfiguracionEntidadCuenta.models_includes), nil, {all: true}).send_response self
    end
  end

  # GET /configuraciones_entidades_cuentas/1
  def show
    return Response.new(params, nil, @configuracion_entidad_cuenta, nil, {all: true}).send_response self
  end


  def actualizar_configuracion_entidad_cuenta
    resultado = ConfiguracionEntidadCuenta.create_update_configuracion_entidad_cuenta(params, @configuracion_entidad_cuenta, true)
    resultado.send_response self
  end

  # PATCH/PUT /configuraciones_entidades_cuentas/1
  def update
    actualizar_configuracion_entidad_cuenta
  end

  def get_parametros_opcionales
    return {
      all:                   params[:all].present? ? params[:all]                                               : true,
    }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_configuracion_entidad_cuenta
      respuesta = set_entidad(ConfiguracionEntidadCuenta, params)
      @configuracion_entidad_cuenta = respuesta.get_data

      return respuesta.send_response self if @configuracion_entidad_cuenta.nil?
    end

end