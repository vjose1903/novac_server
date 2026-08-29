class MarcasController < ApplicationController
  before_action :set_marca, only: [:show, :update, :destroy]

  # GET /marcas
  def index
    @marcas = Marca.all

    render body: MarcaSerializer.collection_to_hash(@marcas).to_json, content_type: 'application/json'
  end

  def getMarcasFiltradas
    arg = params["arg"]

    page = params["page"]
    per_page = params["per_page"]
    paginado = params["paginado"] === "true" ? true : false

    marcas = Marca.filtrarMarcas(arg)

    res = []

    if paginado
      res = marcas.my_paginate(page, per_page)
    else
      res = marcas
    end

    data = paginado ? res.merge("data" => MarcaSerializer.collection_to_hash(res["data"])) : MarcaSerializer.collection_to_hash(res)
    render body: data.to_json, content_type: 'application/json'
  end

  # GET /marcas/1
  def show
    render body: MarcaSerializer.to_hash(@marca).to_json, content_type: 'application/json'
  end

  # POST /marcas
  def create
    @marca = Marca.new(marca_params)

    if @marca.save
      render json: @marca, status: :created, location: @marca
    else
      render json: @marca.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /marcas/1
  def update
    if @marca.update(marca_params)
      render json: @marca
    else
      render json: @marca.errors, status: :unprocessable_entity
    end
  end

  # DELETE /marcas/1
  def destroy
    resultado = borrar_entidad(@marca)
    resultado.send_response self
  end

  private
    # Use callbacks to share common setup or constraints between actions.
		def set_marca
			respuesta = set_entidad(Marca, params)
			@marca = respuesta.get_data

			return respuesta.send_response self if @marca.nil?
		end


    # Only allow a trusted parameter "white list" through.
    def marca_params
      params.permit(:descripcion)
    end
end
