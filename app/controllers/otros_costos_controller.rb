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

	def getOtrosCostosFiltrados
    arg = params["arg"]
    resultado = OtroCosto.filtrarOtroCosto(arg, {all: true})
    resultado.send_response self
  end

	def crear_otro_costo
		parametros       = params
		parametros["id"] = params["id"] if params["id"]

    resultado        = OtroCosto.crear_actualizar_otro_costo(parametros, @otro_costo)
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
    resultado = borrar_entidad(@otro_costo)
    resultado.send_response self
  end

  private
    # Use callbacks to share common setup or constraints between actions.

		def set_otro_costo
			puts " "
			puts "============= ANDO AQUIII =============".yellow
			puts " "
			respuesta = set_entidad(OtroCosto, params)
			@otro_costo = respuesta.get_data

			puts " "
			puts "============= ANDO AQUIII =============".green
			puts " "
			return respuesta.send_response self if @otro_costo.nil?
		end
end
