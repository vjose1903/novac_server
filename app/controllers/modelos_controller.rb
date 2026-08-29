class ModelosController < ApplicationController
  before_action :set_modelo, only: [:show, :update, :destroy]

  # GET /modelos
  def index
    page = params["page"]
    per_page = params["per_page"]
    paginado = params["paginado"] === "true" ? true : false

    @modelos = Modelo.includes(:marca)

    res = []

    if paginado
      res = @modelos.my_paginate(page, per_page)
    else
      res = @modelos
    end

    data = paginado ? res.merge("data" => ModeloSerializer.collection_to_hash(res["data"])) : ModeloSerializer.collection_to_hash(res)
    render body: data.to_json, content_type: 'application/json'
  end

  # GET /modelos/1
  def show
    render body: ModeloSerializer.to_hash(@modelo).to_json, content_type: 'application/json'
  end

  def getModelosPorMarca
    marca = params["marca"]
    modelos = Modelo.includes(:marca).where({ marca_id: marca })

    render body: ModeloSerializer.collection_to_hash(modelos).to_json, content_type: 'application/json'
  end

  def getModelosFiltrados
    arg = params["arg"]

    page = params["page"]
    per_page = params["per_page"]
    paginado = params["paginado"] === "true" ? true : false

    modelos = Modelo.filtrarModelo(arg)

    res = []

    if paginado
      res = modelos.my_paginate(page, per_page)
    else
      res = modelos
    end

    data = paginado ? res.merge("data" => ModeloSerializer.collection_to_hash(res["data"])) : ModeloSerializer.collection_to_hash(res)
    render body: data.to_json, content_type: 'application/json'
  end




  # POST /modelos
  def create
    @modelo = Modelo.new(modelo_params)

    if @modelo.save
      render json: @modelo, status: :created, location: @modelo
    else
      render json: @modelo.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /modelos/1
  def update
    if @modelo.update(modelo_params)
      render json: @modelo
    else
      render json: @modelo.errors, status: :unprocessable_entity
    end
  end

  # DELETE /modelos/1
	def destroy
    resultado = borrar_entidad(@modelo)
    resultado.send_response self
  end

	private

	# Use callbacks to share common setup or constraints between actions.
	def set_modelo
		respuesta = set_entidad(Modelo, params)
		@modelo = respuesta.get_data

		return respuesta.send_response self if @modelo.nil?
	end


  # Only allow a trusted parameter "white list" through.
  def modelo_params
    params.require(:modelo).permit(:marca_id, :descripcion)
  end
end
