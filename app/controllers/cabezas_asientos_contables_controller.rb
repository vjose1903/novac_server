class CabezasAsientosContablesController < ApplicationController
  before_action :set_cabeza_asiento_contable, only: [ :show, :destroy ]

  # GET /cabezas_asientos_contables
  def index
    return Response.new(params, nil, CabezaAsientoContable.all.where({ estado: true}).order('id DESC'), nil, { all: true }).send_response self
  end

  # GET /cabezas_asientos_contables/1
  def show
    return Response.new(params, nil, @cabeza_asiento_contable, nil, { all: true }).send_response self
  end


  def crear_actualizar_asiento_contable
    resultado = CabezaAsientoContable.create_update_asiento_contable(params)
    resultado.send_response self
  end


  # POST /cabezas_asientos_contables
  def create
    crear_actualizar_asiento_contable
  end

  # PATCH/PUT /cabezas_asientos_contables/1
  def update
    crear_actualizar_asiento_contable
  end

  # DELETE /cabezas_asientos_contables/1
  def destroy
    resultado = borrar_entidad(@cabeza_asiento_contable)
    resultado.send_response self
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cabeza_asiento_contable
      respuesta                 = set_entidad(CabezaAsientoContable, params)
      @cabeza_asiento_contable  = respuesta.get_data

      return respuesta.send_response self if @cabeza_asiento_contable.nil?
    end
end
