class GruposDeCuentasController < ApplicationController
  before_action :set_grupo_cuenta, only: [:show, :destroy ]


  # GET /grupos_de_cuentas
  def index
    grupos = GrupoCuenta.all.where({ estado: true}).order('id ASC').includes(:cuentas_contables)
    return Response.new(params, nil, CatalogoCuenta::GrupoCuenta.iterator(grupos), nil).send_response self
  end

  # GET /grupos_de_cuentas/1
  def show

		grupo_temp = [@grupo_cuenta]
		grupo      = CatalogoCuenta::GrupoCuenta.iterator(grupo_temp).first
    return Response.new(params, nil, grupo, nil).send_response self
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
