class ConfigArticulosController < ApplicationController
  before_action :set_config_articulo, only: [:show, :update]

  # GET /config_articulos/1
  def show
    return Response.new(params, nil, @config_articulo, nil, {all: true}).send_response self
  end

  def actualizar_configuracion
    parametros = params
    parametros["id"] = params["id"] if params["id"]

    resultado = ConfigArticulo.update_configuracion(parametros, true)
    resultado.send_response self
  end

  # PATCH/PUT /clientes/1
  def update
    actualizar_configuracion
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_config_articulo
			respuesta = set_entidad(ConfigArticulo, params)
			@config_articulo = respuesta.get_data

			return respuesta.send_response self if @config_articulo.nil?
    end
end
