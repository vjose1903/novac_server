class FamiliasEntidadesContablesController < ApplicationController
  before_action :set_familia_entidad_contable, only: [ :show ]

  # GET /familias_entidades_contables
  def index
    return Response.new(params, nil, FamiliaEntidadContable.all, nil, { all: true }).send_response self
  end

  # GET /familias_entidades_contables/1
  def show
    return Response.new(params, nil, @familia_entidad_contable, nil, { all: true }).send_response self
  end

  def crear_actualizar_familia_entidad_contable

    resultado = FamiliaEntidadContable.create_update_familia_entidad_contable(params, true)
    resultado.send_response self
  end

  # POST /familias_entidades_contables
  def create
    crear_actualizar_familia_entidad_contable
  end

  # PATCH/PUT /familias_entidades_contables/1
  def update
    crear_actualizar_familia_entidad_contable
  end

  private
    def set_familia_entidad_contable
      respuesta                  = set_entidad(FamiliaEntidadContable, params)
      @familia_entidad_contable  = respuesta.get_data

      return respuesta.send_response self if @familia_entidad_contable.nil?
    end
end
