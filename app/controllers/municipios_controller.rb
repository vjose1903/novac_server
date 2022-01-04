class MunicipiosController < ApplicationController
	before_action :set_municipio, only: [:show, :update, :destroy]

	def crear_actualizar_municipio
		parametros = params
		parametros["id"] = params["id"] if params["id"]

		resultado = Municipio.crear_actualizar_municipio(parametros, true)
		resultado.send_response self
	end

	# GET /municipio
	def index
		return Response.new(params, nil, Municipio.all, nil).send_response self
	end
	
	# GET /municipio/1
	def show
		return Response.new(params, nil, @municipio, nil).send_response self
	end

	# POST /municipio
	def create
		crear_actualizar_municipio
	end

	# PATCH/PUT /municipio/1
	def update
		crear_actualizar_municipio
	end

	# DELETE /municipio/1
	def destroy
		@municipio.destroy
	end

	private
		# Use callbacks to share common setup or constraints between actions.
		def set_municipio
			@municipio = Municipio.find(params[:id])
		end

end
