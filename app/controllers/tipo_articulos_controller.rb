class TipoArticulosController < ApplicationController
  before_action :set_tipo_articulo, only: [:show, :update, :destroy]

  # GET /tipo_articulos
  def index
    @tipo_articulos = TipoArticulo.all

    page = params["page"]
    per_page = params["per_page"].to_i
    paginado = params["paginado"] === "true" ? true : false

    res = []

    if paginado
      res = @tipo_articulos.to_a.my_paginate(page, per_page)
    else
      res = @tipo_articulos
    end

    render json: res
  end

  def getTipoArticulosFiltrados
    arg = params["arg"]

    page = params["page"]
    per_page = params["per_page"].to_i
    paginado = params["paginado"] === "true" ? true : false

    tipoArticulos = TipoArticulo.filtrarTipoArticulo(arg)

    res = []

    if paginado
      res = tipoArticulos.to_a.my_paginate(page, per_page)
    else
      res = tipoArticulos
    end

    render json: res
  end

  # GET /tipo_articulos/1
  def show
    render json: @tipo_articulo
  end

  # POST /tipo_articulos
  def create
    @tipo_articulo = TipoArticulo.new(tipo_articulo_params)

    if @tipo_articulo.save
      render json: @tipo_articulo, status: :created, location: @tipo_articulo
    else
      render json: @tipo_articulo.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /tipo_articulos/1
  def update
    if @tipo_articulo.update(tipo_articulo_params)
      render json: @tipo_articulo
    else
      render json: @tipo_articulo.errors, status: :unprocessable_entity
    end
  end

  # DELETE /tipo_articulos/1
  def destroy
    @tipo_articulo.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_tipo_articulo
    @tipo_articulo = TipoArticulo.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def tipo_articulo_params
    params.require(:tipo_articulo).permit(:descripcion)
  end
end
