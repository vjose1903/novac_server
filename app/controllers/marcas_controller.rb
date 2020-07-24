class MarcasController < ApplicationController
  before_action :set_marca, only: [:show, :update, :destroy]

  # GET /marcas
  def index
    @marcas = Marca.all

    render json: @marcas
  end

  def getMarcasFiltradas
    arg = params["arg"]

    page = params["page"]
    per_page = params["per_page"].to_i

    marcas = Marca.filtrarMarcas(arg)

    marcas_paginado = marcas.to_a.my_paginate(page, per_page)

    render json: marcas_paginado
  end

  # GET /marcas/1
  def show
    render json: @marca
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
    @marca.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_marca
    @marca = Marca.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def marca_params
    params.require(:marca).permit(:descripcion)
  end
end
