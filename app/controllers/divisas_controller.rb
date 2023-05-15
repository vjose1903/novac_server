class DivisasController < ApplicationController
  before_action :set_divisa, only:[ :show, :deactivateOrReactivate ]

  # GET /divisas
  def index
    return Response.new(params, nil, Divisa.all.order('id ASC').includes(Divisa.models_includes), nil, { all: true }).send_response self
  end

  # GET /divisas/1
  def show
    return Response.new(params, nil, @divisa, nil, { all: true }).send_response self
  end

  def crear_actualizar_divisa
    resultado = Divisa.create_update_divisa(params, true)
    resultado.send_response self
  end

  # POST /divisas
  def create
    crear_actualizar_divisa
  end

  # PATCH/PUT /divisas/1
  def update
    crear_actualizar_divisa
  end

  # DELETE /divisas/deactivate_or_reactivate/1
  def deactivateOrReactivate
    resultado = @divisa.deactivate_or_reactivate(params)
    resultado.send_response self
  end

  private
    def set_divisa
      respuesta = set_entidad(Divisa, params)
      @divisa = respuesta.get_data

      return respuesta.send_response self if @divisa.nil?
    end
end
