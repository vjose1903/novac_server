class TasasDeCambioController < ApplicationController
  before_action :set_tasa_cambio, only: [ :show, :destroy ]

  # GET /tasas_de_cambio
  def index
    return Response.new(params, nil, TasaCambio.all.order('id ASC'), nil, {all: true}).send_response self
  end

  # GET /tasas_de_cambio/1
  def show
    return Response.new(params, nil, @tasa_cambio, nil, {all: true}).send_response self
  end

  # GET /tasas_de_cambio/custom/get_history_changes
  def getHistoryChanges
    resultado = TasaCambio.get_history_changes(params)
    resultado.send_response self
  end

  # POST /tasas_de_cambio
  def create
    resultado = TasaCambio.create_tasa_cambio(params, nil, true)
    resultado.send_response self
  end

  # PATCH/PUT /tasas_de_cambio/1
  def update
    resultado = TasaCambio.update_tasa_cambio(params)
    resultado.send_response self
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tasa_cambio
      respuesta     = set_entidad(TasaCambio, params)
      @tasa_cambio  = respuesta.get_data
      return respuesta.send_response self if @tasa_cambio.nil?
    end

end

# 1 - 10 - 25 - 40 - 53 - 82