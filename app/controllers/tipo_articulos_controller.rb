class TipoArticulosController < ApplicationController

  before_action :set_tipo_articulo, only: [ :show, :destroy ]

  # GET /tipo_articulos
  def index
    return Response.new(params, nil, TipoArticulo.all, nil, { all: true }).send_response self
  end

  # GET /tipo_articulos/1
  def show
    return Response.new(params, nil, @tipo_articulo, nil, { all: true }).send_response self
  end

  def crear_actualizar_tipo_articulo
    resultado = TipoArticulo.create_update_tipo_articulo(params, true)
    resultado.send_response self
  end

	# POST /tipo_articulos
  def create
    crear_actualizar_tipo_articulo
  end

  # PATCH/PUT /tipo_articulos/1
  def update
    crear_actualizar_tipo_articulo
  end

  private
  def set_tipo_articulo
    respuesta = set_entidad(TipoArticulo, params)
    @tipo_articulo  = respuesta.get_data

    return respuesta.send_response self if @tipo_articulo.nil?
  end
end
