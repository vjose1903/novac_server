class SubTipoArticulosController < ApplicationController
  before_action :set_sub_tipo_articulo, only: [ :show ]

  # GET /sub_tipo_articulos
  def index
    return Response.new(params, nil, SubTipoArticulo.all, nil, { all: true }).send_response self
  end

  # GET /sub_tipo_articulos/1
  def show
    return Response.new(params, nil, @sub_tipo_articulo, nil, { all: true }).send_response self
  end

  def crear_actualizar_sub_tipo_articulo
    resultado = SubTipoArticulo.create_update_sub_tipo_articulo(params, true)
    resultado.send_response self
  end

  # POST /sub_tipo_articulos
  def create
    crear_actualizar_sub_tipo_articulo
  end

  # PATCH/PUT /sub_tipo_articulos/1
  def update
    crear_actualizar_sub_tipo_articulo
  end

  private
    def set_sub_tipo_articulo
      respuesta = set_entidad(SubTipoArticulo, params)
      @sub_tipo_articulo  = respuesta.get_data

      return respuesta.send_response self if @sub_tipo_articulo.nil?
    end
end
