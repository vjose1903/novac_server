class CostoFletesController < ApplicationController
  before_action :set_municipio, only: [:set_costo_flete]
  before_action :set_costo_flete, only: [:show, :update, :destroy]

  # GET /costo_fletes
  def index
    return Response.new(params, nil, CostoFlete.all.where({estado: true}).order('id DESC'), nil, {all: true}).send_response self

  end

  # GET /costo_fletes/1
  def show
    return Response.new(params, nil, @costo_flete, nil, {all: true}).send_response self
  end

  def crear_actualizar_costo
		parametros = costo_flete_params
		parametros["id"] = params["id"] if params["id"]

		resultado = CostoFlete.crear_actualizar_costo(parametros, current_user, true)
		resultado.send_response self
	end

  # POST /costo_fletes
  def create
    crear_actualizar_costo
  end

  # PATCH/PUT /costo_fletes/1
  def update
    crear_actualizar_costo
  end

  # DELETE /costo_fletes/1
  def destroy
    resultado = borrar_entidad(@costo_flete)
    return resultado.send_response self
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_costo_flete

      params[:id] = params[:persona_id] if params[:persona_id]
      respuesta = set_entidad(CostoFlete, params)
      @costo_flete = respuesta.get_data

      return respuesta.send_response self if @costo_flete.nil?
    end

    # Only allow a trusted parameter "white list" through.
    def costo_flete_params
      params.require(:costo_flete).permit(:municipio_id, :costo)
    end
end
