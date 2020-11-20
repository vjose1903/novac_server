class SecuenciaComprobantesController < ApplicationController
  before_action :set_secuencia_comprobante, only: [:show, :update, :destroy]

  # GET /secuencia_comprobantes
  def index
    @secuencia_comprobantes = SecuenciaComprobante.all

    render json: @secuencia_comprobantes
  end

  def getSecuenciaComprobantesFiltrados
    arg = params["arg"]

    page = params["page"]
    per_page = params["per_page"]
    paginado = params["paginado"] === "true" ? true : false

    ncf_ = SecuenciaComprobante.filtrar_ncf(arg)

    res = []

    if paginado
      res = ncf_.to_a.my_paginate(page, per_page)
    else
      res = ncf_
    end

    render json: res
  end

  # GET /secuencia_comprobantes/1
  def show
    render json: @secuencia_comprobante
  end

  # POST /secuencia_comprobantes
  def create
    @secuencia_comprobante = SecuenciaComprobante.new(secuencia_comprobante_params)

    sigue = SecuenciaComprobante.validar_rango(@secuencia_comprobante["tipo_factura_id"], @secuencia_comprobante)

    if sigue[:error]
      return render :json => sigue, status: sigue[:status]
    end

    if @secuencia_comprobante.save
      render json: @secuencia_comprobante, status: :created, location: @secuencia_comprobante
    else
      render json: @secuencia_comprobante.errors, status: :unprocessable_entity
    end
  end

  def getPaqueteRncByEstado
    paquete = SecuenciaComprobante.get_paquete_rnc_by_estado(params[:id], params[:estado])
    render json: paquete, status: paquete[:status]
  end

  # PATCH/PUT /secuencia_comprobantes/1
  def update
    if @secuencia_comprobante.update(secuencia_comprobante_params)
      render json: @secuencia_comprobante
    else
      render json: @secuencia_comprobante.errors, status: :unprocessable_entity
    end
  end
  
  # DELETE /secuencia_comprobantes/1
  def destroy
    if @secuencia_comprobante.estado
      render json: {msg:'Este paquete de comprobantes ta esta activo, no se puede eliminar.'}, status: :unprocessable_entity
    else
      @secuencia_comprobante.destroy
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_secuencia_comprobante
    @secuencia_comprobante = SecuenciaComprobante.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def secuencia_comprobante_params
    params.fetch(:secuencia_comprobante).permit(:tipo_factura_id, :secuencia, :referencia, :desde, :hasta, :fecha_compra, :fecha_valida, :estado, :usado)
  end
end
