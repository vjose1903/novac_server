class GruposDeCuentasController < ApplicationController
  before_action :set_grupo_cuenta, only: [:show, :update, :destroy ]


  # GET /grupos_de_cuentas
  def index
    return Response.new(params, nil, GrupoCuenta.all.where({ estado: true}).order('id DESC'), nil, {all: true}).send_response self
  end

  # GET /grupos_de_cuentas/1
  def show
    return Response.new(params, nil, @grupo_cuenta, nil, {all: true}).send_response self
  end

  def crear_actualizar_grupo_cuenta
    resultado = GrupoCuenta.create_update_grupo_cuenta(params, true)
    resultado.send_response self
  end

  # POST /grupos_de_cuentas
  def create
    crear_actualizar_grupo_cuenta
  end

  # PATCH/PUT /grupos_de_cuentas/1
  def update
    crear_actualizar_grupo_cuenta
  end

  # DELETE /grupos_de_cuentas/1
	def destroy
    resultado = borrar_entidad(@grupo_cuenta)
    resultado.send_response self
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_grupo_cuenta

      respuesta = set_entidad(GrupoCuenta, params)
      @grupo_cuenta = respuesta.get_data

      return respuesta.send_response self if @grupo_cuenta.nil?
  end
end
