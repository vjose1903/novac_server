class ContenidoArticulosController < ApplicationController
  before_action :set_contenido_articulo, only: [:show, :update, :destroy]

  # GET /contenido_articulos
  def index
    @contenido_articulos = ContenidoArticulo.all

    render json: @contenido_articulos
  end

  # GET /contenido_articulos/1
  def show
    render json: @contenido_articulo
  end

  def getCondicionContenido
    @condicionContendio = ContenidoArticulo.get_condicion_contenido
    render json: @condicionContendio
  end

  def getCondicionContenidoById
    @condicionContendio = ContenidoArticulo.get_condicion_contenido_by_id(params[:id])
    render json: @condicionContendio
  end

  # POST /contenido_articulos
  def create
    @contenido_articulo = ContenidoArticulo.new(contenido_articulo_params)

    if @contenido_articulo.save
      render json: @contenido_articulo, status: :created, location: @contenido_articulo
    else
      render json: @contenido_articulo.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /contenido_articulos/1
  def update
    if @contenido_articulo.update(contenido_articulo_params)
      render json: @contenido_articulo
    else
      render json: @contenido_articulo.errors, status: :unprocessable_entity
    end
  end

  # DELETE /contenido_articulos/1
  def destroy
    @contenido_articulo.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_contenido_articulo
    @contenido_articulo = ContenidoArticulo.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def contenido_articulo_params
    params.require(:contenido_articulo).permit(:articulo_id, :referencia, :costo, :precio, :cantidad, :medida, :calcular_itbis, :condicion)
  end
end
