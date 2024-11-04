class ChequesController < ApplicationController
  before_action :set_cheque, only: %i[ show update destroy ]

  # GET /cheques
  def index
    return Response.new(params, nil, Cheque.all.where({ estado: STATUS.active }).order('id DESC'), nil, { all: true }).send_response self
  end

  # GET /cheques/1
  def show
    return Response.new(params, nil, @cheque, nil, { all: true }).send_response self
  end

  def manage_cheques
    resultado = Cheque.manage_cheque( params )
    resultado.send_response self
  end

  # POST /cheques
  def create
    manageCheques
  end

  # PATCH/PUT /cheques/1
  def update
    manageCheques
  end

  # DELETE /cheques/1
  def destroy
    resultado = borrar_entidad(@cheque)
    resultado.send_response self
  end

  private
    def set_cheque
      respuesta = set_entidad(Cheque, params)
      @cheque   = respuesta.get_data

      return respuesta.send_response self if @cheque.nil?
    end
end
