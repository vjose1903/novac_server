class ModelosController < ApplicationController
  before_action :set_modelo, only: [:show, :update, :destroy]

  # GET /modelos
  def index
    page = params["page"]
    per_page = params["per_page"].to_i
    paginado = params["paginado"] === "true" ? true : false

    @modelos = Modelo.all

    res = []

    if paginado
      res = @modelos.to_a.my_paginate(page, per_page)
    else
      res = @modelos
    end

    render json: res
  end

  # GET /modelos/1
  def show
    render json: @modelo
  end

  def getModelosPorMarca
    marca = params["marca"]
    modelos = Modelo.where({ marca_id: marca })

    render json: modelos
  end

  def getModelosFiltrados
    arg = params["arg"]

    page = params["page"]
    per_page = params["per_page"].to_i
    paginado = params["paginado"] === "true" ? true : false

    modelos = Modelo.filtrarModelo(arg)

    modelos_ = Modelo.parsearModelosFiltro(modelos)

    res = []

    if paginado
      res = modelos.to_a.my_paginate(page, per_page)
    else
      res = modelos
    end

    render json: res
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
    @modelo.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_modelo
    @modelo = Modelo.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def modelo_params
    params.require(:modelo).permit(:marca_id, :descripcion)
  end
end
