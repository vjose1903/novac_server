class MovimientosInventariosController < ApplicationController
  before_action :set_movimientos_inventario, only: [:show, :update, :destroy]

  # GET /movimientos_inventarios
  def index
    @movimientos_inventarios = MovimientosInventario.all

    render json: @movimientos_inventarios
  end

  # GET /movimientos_inventarios/1
  def show
    render json: @movimientos_inventario
  end

  # POST /movimientos_inventarios
  def create
    ActiveRecord::Base.transaction do
      @movimientos_inventario = MovimientosInventario.new(movimientos_inventario_params)
      m = movimientos_inventario_params

      articulo_ = Articulo.find_by_id(m["articulo_id"])
      articulo_ = Articulo.parseal(articulo_)

      if articulo_ == [] || articulo_ == nil
        return render json: { msg: "Error buscando articulo." }, status: 404
      end

      MovimientosInventario.movimientos_de_inventario(m["accion"], articulo_, m["medida"], m["cantidad"])

      articulo_ = Articulo.find_by_id(m["articulo_id"])
      articulo_ = Articulo.parseal(articulo_)

      obj = {
        movimientosinventario: @movimientos_inventario,
        articulo: articulo_,
      }

      if @movimientos_inventario.save
        render json: obj, status: :created, location: @movimientos_inventario
      else
        render json: @movimientos_inventario.errors, status: :unprocessable_entity
      end
    end
  end

  # PATCH/PUT /movimientos_inventarios/1
  def update
    if @movimientos_inventario.update(movimientos_inventario_params)
      render json: @movimientos_inventario
    else
      render json: @movimientos_inventario.errors, status: :unprocessable_entity
    end
  end

  # DELETE /movimientos_inventarios/1
  def destroy
    @movimientos_inventario.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_movimientos_inventario
    @movimientos_inventario = MovimientosInventario.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def movimientos_inventario_params
    params.fetch(:movimientos_inventario).permit(:user_id, :articulo_id, :cantidad, :accion, :motivo, :medida)
  end
end
