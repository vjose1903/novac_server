class PeriodosFiscalesController < ApplicationController
  before_action :set_periodo_fiscal, only: [ :show, :destroy ]

  # GET /periodos_fiscales
  def index
    if has_filter_target(params)
      resultado = PeriodoFiscal.filtrar(params[:filter_target], set_paginate_options(params))
      resultado.send_response self
    else

      return Response.new(params, nil, PeriodoFiscal.all.where({ estado: true}).order('id DESC'), nil, {all: true}).send_response self

    end
  end

  # GET /periodos_fiscales/1
  def show
    return Response.new(params, nil, @periodo_fiscal, nil, {all: true}).send_response self
  end

  def crear_actualizar_periodo_fiscal
    resultado = PeriodoFiscal.create_periodo_fiscal(params, true)
    resultado.send_response self
  end

  # POST /periodos_fiscales
  def create
    crear_actualizar_periodo_fiscal
  end

  # PATCH/PUT /periodos_fiscales/1
  def update
    crear_actualizar_periodo_fiscal
  end

  # DELETE /periodos_fiscales/1
  def destroy
    resultado = borrar_entidad(@periodo_fiscal)
    resultado.send_response self
  end

  def openNewPeriodo
    resultado = PeriodoFiscal.open_new_periodo()
    resultado.send_response self
  end
  def isOpenMonth
    isOpen    = PeriodoFiscal.is_open_month(params[:fecha])

    resultado =  Response.new(params, nil, {isOpen: isOpen}, nil, nil)
    resultado.send_response self
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_periodo_fiscal
      respuesta = set_entidad(PeriodoFiscal, params)
      @periodo_fiscal = respuesta.get_data

      return respuesta.send_response self if @periodo_fiscal.nil?
  end
end
