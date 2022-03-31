class OtrosCostosController < ApplicationController
  before_action :set_otro_costo, only: [:show, :update, :destroy]

  # GET /otros_costos
  def index
    return Response.new(params, nil, OtroCosto.all.where({ estado: true}).order('id DESC'), nil, nil).send_response self
  end

  # GET /otros_costos/1
  def show
    return Response.new(params, nil, @articulo, nil, nil).send_response self
  end

	def crear_otro_costo
		parametros       = params
		parametros["id"] = params["id"] if params["id"]

    resultado        = OtroCosto.crear_actualizar_otro_costo(parametros, @otros_costos, true)
		resultado.send_response self
	end

	# POST /otros_costos
	def create
    @otros_costos = nil
    crear_otro_costo
  end

  # PATCH/PUT /otros_costos/1
  def update
    crear_otro_costo
  end

  # DELETE /otros_costos/1
  def destroy
    @otro_costo.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_otro_costo
      @otro_costo = OtroCosto.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def otro_costo_params
      params.require(:otro_costo).permit(:descripcion, :costo)
    end
end
