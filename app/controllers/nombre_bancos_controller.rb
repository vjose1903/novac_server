class NombreBancosController < ApplicationController
  before_action :set_nombre_banco, only:[ :show ]

  # GET /nombre_bancos
  def index
    return Response.new(params, nil, NombreBanco.order('nombre ASC'), nil, { all: true }).send_response self
  end

  # GET /nombre_bancos/1
  def show
    return Response.new(params, nil, @nombre_banco, nil, { all: true }).send_response self
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_nombre_banco
      respuesta = set_entidad(NombreBanco, params)
      @nombre_banco = respuesta.get_data

      return respuesta.send_response self if @nombre_banco.nil?
    end
end
