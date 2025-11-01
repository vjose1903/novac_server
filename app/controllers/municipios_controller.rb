class MunicipiosController < ApplicationController
	before_action :set_municipio, only: [:show, :destroy]
	# GET /municipio
	def index
		return Response.new(params, nil, Municipio.all, nil, get_parametros_opcionales).send_response self
	end

	# GET /municipio/1
	def show
		return Response.new(params, nil, @municipio, nil, get_parametros_opcionales).send_response self
	end

	def crear_actualizar_municipio
		resultado = Municipio.crear_actualizar_municipio(params, true)
		resultado.send_response self
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

	def get_parametros_opcionales
		optional_params = {
			all:    validate_optional_param(params, 'all')    ? params['all'].to_boolean    : true,
			id:     validate_optional_param(params, 'id')     ? params['id'].to_boolean     : false,
			nombre: validate_optional_param(params, 'nombre') ? params['nombre'].to_boolean : false,
			codigo: validate_optional_param(params, 'codigo') ? params['codigo'].to_boolean : false,
			provincia: {
				all: false,
				id:     validate_optional_param(params, 'provincia.id')     ? params['provincia.id'].to_boolean     : false,
				nombre: validate_optional_param(params, 'provincia.nombre') ? params['provincia.nombre'].to_boolean : false,
			}

		}
	end

	private
		# Use callbacks to share common setup or constraints between actions.
		def set_municipio
			respuesta = set_entidad(Municipio, params)
			@municipio = respuesta.get_data

			return respuesta.send_response self if @municipio.nil?
		end

end
