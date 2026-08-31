class NotasController < ApplicationController
  before_action :set_nota, only: [:show, :update, :destroy]

  # GET /notas
	def index
    return Response.new(params, nil, Nota.all.where({ estado: true}).order('id DESC'), nil, {all: true}, Nota.models_includes).send_response self
  end

  # GET /notas/1
  def show
		return Response.new(params, nil, @nota, nil, {all: true}, Nota.models_includes).send_response self
	end

	def getNotasFiltradas


    resultado = Nota.filtrarNota(params, set_paginate_options(params))
    resultado.send_response self
  end

  # POST /notas
  def create
		resultado = Nota.create_nota(params)
		resultado.send_response self
  end

  # PATCH/PUT /notas/1
  def update
    # if @nota.update(nota_params)
    #   render json: @nota
    # else
    #   render json: @nota.errors, status: :unprocessable_entity
    # end
  end

  def cancelarNota
    resultado = Nota.anular_nota(params)
    resultado.send_response self
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_nota
			respuesta = set_entidad(Nota, params)
			@nota = respuesta.get_data

			return respuesta.send_response self if @nota.nil?
    end
end
