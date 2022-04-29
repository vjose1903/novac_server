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

  # POST /secuencia_comprobantes
  def create
    @secuencia_comprobante = SecuenciaComprobante.new(secuencia_comprobante_params)

    sigue = SecuenciaComprobante.validar_rango(@secuencia_comprobante['id'], @secuencia_comprobante, 'new')

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
    resultado = SecuenciaComprobante.get_paquete_rnc_by_estado(params["id"], params["estado"])
    resultado.send_response self
  end

  # PATCH/PUT /secuencia_comprobantes/1
  def update
    @secuencia_comprobante['id']
    sigue = SecuenciaComprobante.validar_rango(@secuencia_comprobante['id'], secuencia_comprobante_params, 'update')

    if sigue[:error]
      return render :json => sigue, status: sigue[:status]
    end

    if secuencia_comprobante_params['desde'] > secuencia_comprobante_params['hasta']
      return render :json => { :error => true, :msg => "El inicio del paquete no puede ser mayor al final del mismo.", :body => {} }, status: 400
    end

    if secuencia_comprobante_params['desde'] == secuencia_comprobante_params['hasta']
      return render :json => { :error => true, :msg => "El final del paquete debe de ser mayor al inicio del mismo.", :body => {} }, status: 400
    end

    if @secuencia_comprobante['estado'] &&  @secuencia_comprobante['desde'] != secuencia_comprobante_params['desde']
      return render :json => { :error => true, :msg => "Este paquete ya esta en uso no puede cambiar el inicio del paquete.", :body => {} }, status: 400
    end


    if @secuencia_comprobante.update(secuencia_comprobante_params)
      render json: @secuencia_comprobante
    else
      render json: @secuencia_comprobante.errors, status: :unprocessable_entity
    end
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
  def secuencia_comprobante_params
    params.fetch(:secuencia_comprobante).permit(:tipo_factura_id, :secuencia, :referencia, :desde, :hasta, :fecha_compra, :fecha_valida, :estado, :usado)
  end
end
