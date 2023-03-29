class CategoriasEntidadesContablesController < ApplicationController
  before_action :set_categoria_entidad_contable, only: [ :show ]

  # GET /categorias_entidades_contables
  def index
    return Response.new(params, nil, CategoriaEntidadContable.all, nil, { all: true }).send_response self
  end

  # GET /categorias_entidades_contables/1
  def show
    return Response.new(params, nil, @categoria_entidad_contable, nil, { all: true }).send_response self
  end

  def crear_actualizar_categoria_entidad_contable
    resultado = CategoriaEntidadContable.create_update_categoria_entidad_contable(params, true)
    resultado.send_response self
  end

  # POST /categorias_entidades_contables
  def create
    crear_actualizar_categoria_entidad_contable
  end

  # PATCH/PUT /categorias_entidades_contables/1
  def update
    crear_actualizar_categoria_entidad_contable
  end

  private
    def set_categoria_entidad_contable
      respuesta                  = set_entidad(CategoriaEntidadContable, params)
      @categoria_entidad_contable  = respuesta.get_data

      return respuesta.send_response self if @categoria_entidad_contable.nil?
    end
end
