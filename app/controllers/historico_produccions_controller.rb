class HistoricoProduccionsController < ApplicationController
  before_action :set_historico_produccion, only: [:show, :update, :destroy]

  # GET /historico_produccions
  def index
    @historico_produccions = HistoricoProduccion.all
    render json: @historico_produccions
  end

  # GET /historico_produccions/1
  def show
    render json: @historico_produccion
  end

  def parseal(objeto)
    att = objeto.attributes
    articuloSelect = Articulo.find_by_id(objeto["articulo_id"])
    responsableProd = User.find_by_id(objeto["user_id"])

    att["articulo"] = "#{articuloSelect["nombre"]}"
    att["usuario"] = "#{responsableProd["nombre"]} #{responsableProd["apellido"]}"
    return att
  end

  # POST /historico_produccions
  def create
    ActiveRecord::Base.transaction do
      @historico_produccion = HistoricoProduccion.new(historico_produccion_params)

      # obj = { msg: "pruebas", body: @historico_produccion }
      # return render json: obj, status: :unprocessable_entity

      if @historico_produccion.save
        params["ingredientes"].each do |ingrediente|
          articulo = Articulo.find_by_id(ingrediente["articulo_id"])
          mov = (articulo["existencia"] - ingrediente["cantidad"])
          unless articulo.update({ existencia: mov })
            render json: articulo.errors, status: :unprocessable_entity
            raise ActiveRecord::Rollback
          end
        end

        productoTerminado = Articulo.find_by_id(params["articulo_id"])
        movProd = (productoTerminado["existencia"] + params["cantidad"])
        unless productoTerminado.update({ existencia: movProd })
          render json: productoTerminado.errors, status: :unprocessable_entity
          raise ActiveRecord::Rollback
        end

        render json: @historico_produccion, status: :created, location: @historico_produccion
      else
        render json: @historico_produccion.errors, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end
  end

  # PATCH/PUT /historico_produccions/1
  def update
    ActiveRecord::Base.transaction do
      if @historico_produccion.update(historico_produccion_params)
        render json: @historico_produccion
      else
        render json: @historico_produccion.errors, status: :unprocessable_entity
      end
    end
  end

  # DELETE /historico_produccions/1
  def destroy
    @historico_produccion.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_historico_produccion
    @historico_produccion = HistoricoProduccion.find(params[:id])
    @ingredientes = params[:ingredientes]
  end

  # Only allow a trusted parameter "white list" through.
  def historico_produccion_params
    params.require(:historico_produccion).permit(:user_id, :articulo_id, :cantidad, :medida)
  end
end
