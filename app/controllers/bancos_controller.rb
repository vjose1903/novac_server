class BancosController < ApplicationController
  before_action :set_banco, only: [ :show, :destroy ]

  # GET /bancos
  def index
    return Response.new(params, nil, Banco.all.where({ estado: true }).order('id ASC'), nil, { all: true }).send_response self
  end

  # GET /bancos/1
  def show
    return Response.new(params, nil, @banco, nil, { all: true }).send_response self
  end

  def getBancosFiltrados
    resultado = Banco.filtrarBancos(params, parse_pagination_params(params))
    resultado.send_response self
  end

  def crear_actualizar_banco
    resultado = Banco.create_update_banco(params, true)
    resultado.send_response self
  end

  # POST /bancos
  def create
    crear_actualizar_banco
  end

  # PATCH/PUT /bancos/1
  def update
    crear_actualizar_banco
  end

  # DELETE /bancos/1
  def destroy
		resultado = borrar_entidad(@banco)
    resultado.send_response self
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_banco
			respuesta = set_entidad(Banco, params)
      @banco    = respuesta.get_data

      return respuesta.send_response self if @banco.nil?
    end
end
