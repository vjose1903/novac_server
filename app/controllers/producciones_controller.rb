class ProduccionesController < ApplicationController
  before_action :set_produccion, only: [:show, :update, :destroy]

  # GET /producciones
  def index
    @producciones = Produccion.all

    render json: @producciones
  end

  # GET /producciones/1
  def show
    render json: @produccion
  end

  # POST /producciones
  def create
    Produccion.transaction do
      att = produccion_params

      @produccion = Produccion.new(produccion_params)
      @produccion.numero = SecuenciaFactura.find_secuencia(16)
      @produccion.fecha_equivalente = att["fecha_equivalente"] ? att["fecha_equivalente"] : DateTime.now

      if @produccion.save
        params["detalles_produccion_attributes"].each do |producto_en_produccion|
          productoTerminado = Articulo.find_by_id(producto_en_produccion["articulo_id"])
          formula = FormulasProductosTerminado.where({ articulo_id: productoTerminado.id })

          formula.each do |ingrediente|
            articulo_ingrediente = Articulo.find_by_id(ingrediente["articulo_combo"])

            cantidadFormula = ingrediente["cantidad"].to_d / 100

            cantidad_calculada = cantidadFormula * producto_en_produccion["cantidad_en_unidades"]

            mov = (articulo_ingrediente["existencia"] - cantidad_calculada)
            unless articulo_ingrediente.update({ existencia: mov })
              render json: articulo_ingrediente.errors, status: :unprocessable_entity
              raise ActiveRecord::Rollback
            end
          end

          movProd = (productoTerminado["existencia"] + producto_en_produccion["cantidad_en_unidades"])
          unless productoTerminado.update({ existencia: movProd })
            render json: productoTerminado.errors, status: :unprocessable_entity
            raise ActiveRecord::Rollback
          end
        end
        # render json: { msg: "pruebas" }, status: :unprocessable_entity
        # raise ActiveRecord::Rollback

        updateSecuencias
        # render json: @produccion, status: :created, location: @produccion
      else
        render json: @produccion.errors, status: :unprocessable_entity
      end
    end
  end

  def updateSecuencias
    secuencia_produccion = SecuenciaFactura.find_by_id(16)

    actual = secuencia_produccion["secuencia"]
    secuencia_produccion["secuencia"] = actual + 1

    if secuencia_produccion.save!
      # produccion = Produccion.parsearData(@produccion)
      render json: @produccion, status: :created, location: @cabecera_conduce
    else
    end
  end

  # PATCH/PUT /producciones/1
  def update
    if @produccion.update(produccion_params)
      render json: @produccion
    else
      render json: @produccion.errors, status: :unprocessable_entity
    end
  end

  # DELETE /producciones/1
  def destroy
    @produccion.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_produccion
    @produccion = Produccion.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def produccion_params
    params.require(:produccion).permit(:user_id, :numero, :fecha_equivalente,
                                       detalles_produccion_attributes: [:produccion_id, :articulo_id, :cantidad, :cantidad_en_unidades, :medida])
  end
end
