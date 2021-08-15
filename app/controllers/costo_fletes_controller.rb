class CostoFletesController < ApplicationController
  before_action :set_municipio, only: [:set_costo_flete]
  before_action :set_costo_flete, only: [:show, :update, :destroy]

  # GET /costo_fletes
  def index
    return Response.new(nil, CostoFlete.all, nil, {}).send_response self
  end
  
  # GET /costo_fletes/1
  def show
    return Response.new(nil, @costo_flete, nil, {}).send_response self    
  end

  def crear_actualizar_costo
		parametros = costo_flete_params
		parametros["id"] = params["id"] if params["id"]

		resultado = CostoFlete.crear_actualizar_costo(parametros, true)
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
    @costo_flete.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_costo_flete
      params[:id] = params[:persona_id] if params[:persona_id] 
      respuesta = set_entidad(CostoFlete, params)
      @costo_flete = respuesta.get_data
      
      return respuesta.send_response self if @persona.nil?
    end

    # Only allow a trusted parameter "white list" through.
    def costo_flete_params
      params.require(:costo_flete).permit(:municipio_id, :costo)
    end
end
