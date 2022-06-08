class SecuenciaComprobantesController < ApplicationController
  before_action :set_secuencia_comprobante, only: [:show, :update, :destroy]

  # GET /secuencia_comprobantes
  def index
    @secuencia_comprobantes = SecuenciaComprobante.all

    render json: @secuencia_comprobantes
  end

  # GET /secuencia_comprobantes/1
  def show
    render json: @secuencia_comprobante
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

	def crear_actualizar_ncf
		parametros = params
		parametros["id"] = params["id"] if params["id"]
    resultado = SecuenciaComprobante.create_update_ncf(parametros, true)
		resultado.send_response self
	end

  # POST /secuencia_comprobantes
  def create
		crear_actualizar_ncf
  end

	# PATCH/PUT /secuencia_comprobantes/1
	def update
		crear_actualizar_ncf
	end

  def getPaqueteRncByEstado
    resultado = SecuenciaComprobante.get_paquete_rnc_by_estado(params["id"], params["estado"])
    resultado.send_response self
  end



	def destroy
		res = Response.new(nil, HTTP_STATUS_CODE[:conflict])

		if @secuencia_comprobante.estado
			res.add_msg('Este paquete de comprobantes esta activo, no se puede eliminar.')
		elsif @secuencia_comprobante.usado
			res.add_msg('Este paquete de comprobantes ya esta usado, no se puede eliminar.')
		else
			res = borrar_entidad(@secuencia_comprobante)
		end

		res.send_response self
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_secuencia_comprobante
    @secuencia_comprobante = SecuenciaComprobante.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def secuencia_comprobante_paramsa
    params.fetch(:secuencia_comprobante).permit(:tipo_factura_id, :secuencia, :referencia, :desde, :hasta, :fecha_compra, :fecha_valida, :estado, :usado)
  end
end
