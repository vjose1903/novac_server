class TransferenciasController < ApplicationController
  before_action :set_transferencia, only:[ :show, :anularTransferencia ]

  # GET /transferencias
  def index
    return Response.new(params, nil, Transferencia.all.where({ estado: true}).order('id ASC').includes(Transferencia.models_includes), nil, { all: true }).send_response self
  end

  # GET /transferencias/1
  def show
    return Response.new(params, nil, @transferencia, nil, { all: true }).send_response self
  end

  def  getTransferenciasFiltradas
    resultado = Transferencia.filtrarTransferencias(params, set_paginate_options(params))
    resultado.send_response self
  end

  def crear_actualizar_transferencia
    res = Transferencia.create_update_transferencia(params)
    res.send_response self
  end

  # POST /transferencias
  def create
    crear_actualizar_transferencia
  end

  # PATCH/PUT /transferencias/1
  def update
    crear_actualizar_transferencia
  end

  # DELETE /transferencias/anular/1
  def anularTransferencia
    resultado = @transferencia.anular_registro
    resultado.send_response self
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transferencia
      respuesta = set_entidad(Transferencia, params)
      @transferencia = respuesta.get_data

      return respuesta.send_response self if @transferencia.nil?
    end
end
