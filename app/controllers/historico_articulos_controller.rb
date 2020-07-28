class HistoricoArticulosController < ApplicationController
  before_action :set_historico_articulo, only: [:show, :update, :destroy]

  # GET /historico_articulos
  def index
    @historico_articulos = HistoricoArticulo.all

    render json: @historico_articulos
  end

  # GET /historico_articulos/1
  def show
    render json: @historico_articulo
  end

  # POST /historico_articulos
  def create
    @historico_articulo = HistoricoArticulo.new(historico_articulo_params)

    if @historico_articulo.save
      render json: @historico_articulo, status: :created, location: @historico_articulo
    else
      render json: @historico_articulo.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /historico_articulos/1
  def update
    if @historico_articulo.update(historico_articulo_params)
      render json: @historico_articulo
    else
      render json: @historico_articulo.errors, status: :unprocessable_entity
    end
  end

  # DELETE /historico_articulos/1
  def destroy
    @historico_articulo.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_historico_articulo
    @historico_articulo = HistoricoArticulo.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def historico_articulo_params
    params.require(:historico_articulo).permit(:articulo_id, :suplidor_id, :marca_id, :modelo_id, :tipo_articulo_id, :identificador, :nombre, :color,
                                               :costo_principal, :precio_principal, :existencia, :codigo, :medida, :is_detallable, :aviso_existencia,
                                               :medida_alerta, :estado, :is_combo, :secuencia, :user_id, :agotado,
                                               :medida_hijo, :costo_hijo, :precio_hijo, :cantidad_hijo, :referencia_hijo, :medida_padre, :costo_padre,
                                               :precio_padre, :cantidad_padre, :referencia_padre)
  end
end
