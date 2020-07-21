class ArticulosController < ApplicationController
  before_action :set_articulo, only: [:show, :update, :destroy]

  # GET /articulos
  def index
    @articulos = []
    Articulo.all.each do |articulo|
      if articulo["estado"] == true
        @articulos.push(articulo)
      end
    end
    render json: @articulos
  end

  def getArticuloByNameObyCodigo
    tipo_ = params[:tipo]
    nom_ = params[:nombre]

    articulos_ = []
    @articulos = Articulo.get_articulo_by_name_o_by_codigo(tipo_, nom_)

    @articulos.each do |art|
      articulos_.push(art)
    end

    render json: articulos_
  end

  # GET /articulos/1
  def show
    @articulo
    if @articulo["estado"] == false
      @articulo = { "nombre": "Este articulo esta desactivado." }
    end
    render json: @articulo
  end

  # POST /articulos
  def create
    @articulo = Articulo.new(articulo_params)

    unless @articulo.save
      render json: @articulo.errors, status: :unprocessable_entity
    else
      set_secuencia
    end
  end

  def set_secuencia
    lastArticulo = @articulo
    @codigoSiguiente = "%05d" % lastArticulo["id"].to_s
    if lastArticulo.update({ codigo: @codigoSiguiente })
      render json: @articulo, status: :created, location: @articulo
    else
      render json: lastArticulo.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /articulos/1
  def update
    if @articulo.update(articulo_params)
      render json: @articulo
    else
      render json: @articulo.errors, status: :unprocessable_entity
    end
  end

  # DELETE /articulos/1
  def destroy
    @articulo.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_articulo
    @articulo = Articulo.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def articulo_params
    params.require(:articulo).permit(:suplidor_id, :marca_id, :modelo_id, :tipo_articulo_id, :identificador, :nombre, :color,
                                     :costo_principal, :precio_principal, :existencia, :codigo, :medida, :is_detallable,
                                     :aviso_existencia, :medida_alerta, :estado, :is_combo, :unico, :agotado)
  end
end
