class MantenimientoArticulosController < ApplicationController
  before_action :set_mantenimiento_articulo, only: [:show, :update, :destroy]

  # GET /mantenimiento_articulos
  def index
    # @mantenimiento_articulos = MantenimientoArticulo.all

    @mantenimiento_articulos = []

    MantenimientoArticulo.all.each do |historial|
      @mantenimiento_articulos.push(parsearData(historial))
    end
    render json: @mantenimiento_articulos
  end

  # GET /mantenimiento_articulos/1
  def show
    mante = parsearData(@mantenimiento_articulo)
    render json: mante
  end

  def getOneArticuloByDate
    articulos = MantenimientoArticulo.get_one_articulo_by_date(params[:date], params[:articulo_id])

    render json: articulos
  end

  def getAllArticulosByDate
    articulos = []
    articulos = MantenimientoArticulo.get_all_articulos_by_date(params[:date])

    render json: articulos
  end

  def getHistoricoByIdArticulo
    historialById = []
    historico = MantenimientoArticulo.get_historico_by_id_articulo(params[:id])
    historico.each do |historial|
      historialById.push(parsearData(historial))
    end
    render json: historialById
  end

  def parsearData(data)
    att = data.attributes
    usuario = data.user
    att["user"] = "#{usuario["nombre"]} #{usuario["apellido"]}"
    return att
  end

  # POST /mantenimiento_articulos
  def create
    @mantenimiento_articulo = MantenimientoArticulo.new(mantenimiento_articulo_params)

    if @mantenimiento_articulo.save
      render json: @mantenimiento_articulo, status: :created, location: @mantenimiento_articulo
    else
      render json: @mantenimiento_articulo.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /mantenimiento_articulos/1
  def update
    if @mantenimiento_articulo.update(mantenimiento_articulo_params)
      render json: @mantenimiento_articulo
    else
      render json: @mantenimiento_articulo.errors, status: :unprocessable_entity
    end
  end

  # DELETE /mantenimiento_articulos/1
  def destroy
    @mantenimiento_articulo.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_mantenimiento_articulo
    @mantenimiento_articulo = MantenimientoArticulo.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def mantenimiento_articulo_params
    params.require(:mantenimiento_articulo).permit(:articulo_id, :user_id, :ant_medidaAlerta, :ant_nombre, :ant_suplidor, :ant_medida, :ant_costoP, :ant_precioP, :ant_alertaExistencia, :ant_isDetallable, :ant_tipoArticuloId, :ant_medidaPadre,
                                                   :ant_costoPadre, :ant_precioPadre, :ant_cantidadPadre, :ant_medidaHijo, :ant_costoHijo, :ant_precioHijo, :ant_cantidadHijo, :ant_idPadre, :ant_idHijo, :ant_referenciaPadre, :secuencia,
                                                   :ant_referenciaHijo, :ant_calcularItbis, :ant_isCombo, :is_materia_prima, :calcular_saco,)
  end
end
