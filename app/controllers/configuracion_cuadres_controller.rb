class ConfiguracionCuadresController < ApplicationController
  before_action :set_configuracion_cuadre, only: [:show, :update]

  # GET /configuracion_cuadres/1
  def show
    return Response.new(params, nil, @configuracion_cuadre, nil, {all: true}).send_response self
  end

  def actualizar_configuracion
    parametros = params
    parametros["id"] = params["id"] if params["id"]

    resultado = ConfiguracionCuadre.update_configuracion(parametros, true)
    resultado.send_response self
  end

  # PATCH/PUT /configuracion_cuadres/1
  def update
    actualizar_configuracion
  end

  private

    def set_configuracion_cuadre
      respuesta = set_entidad(ConfiguracionCuadre, params)
      @configuracion_cuadre = respuesta.get_data

      return respuesta.send_response self if @configuracion_cuadre.nil?
    end
end
