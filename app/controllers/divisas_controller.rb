class DivisasController < ApplicationController
  before_action :set_divisa, only:[ :show, :destroy ]

  # GET /divisas
  def index
    return Response.new(params, nil, Divisa.all.where({ estado: true}).order('id DESC').includes(Divisa.models_includes), nil, {all: true}).send_response self
  end

	# GET /divisas/1
	def show
		return Response.new(params, nil, @divisa, nil, {all: true}).send_response self
	end

  def crear_actualizar_divisa
    resultado = Divisa.create_update_divisa(params, true)
    resultado.send_response self
  end

  # POST /divisas
  def create
    crear_actualizar_divisa
  end

  # PATCH/PUT /divisas/1
  def update
    crear_actualizar_divisa
  end

  # DELETE /divisas/1
  def destroy
    resultado = borrar_entidad(@divisa)
    resultado.send_response self
  end

  private
    def set_divisa
			respuesta = set_entidad(Divisa, params)
			@divisa = respuesta.get_data

			return respuesta.send_response self if @divisa.nil?
		end
end
