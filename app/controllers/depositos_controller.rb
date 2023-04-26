class DepositosController < ApplicationController
  before_action :set_deposito, only: [ :show, :destroy ]

  # GET /depositos
  def index
    return Response.new(params, nil, Deposito.all.where({ estado: true}).order('id ASC'), nil).send_response self
  end

  # GET /depositos/1
  def show
    return Response.new(params, nil, @deposito, nil, { all: true }).send_response self
  end

  def crear_actualizar_deposito
    res = Deposito.create_update_deposito(params, nil, true)
    res.send_response self
  end

  # POST /depositos
  def create
    crear_actualizar_deposito
  end

  # PATCH/PUT /depositos/1
  def update
    crear_actualizar_deposito
  end

  # DELETE /depositos/1
  def destroy
    resultado = borrar_entidad(@deposito)
    resultado.send_response self
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_deposito
      respuesta = set_entidad(Deposito, params)
      @deposito = respuesta.get_data

      return respuesta.send_response self if @deposito.nil?
    end
end
