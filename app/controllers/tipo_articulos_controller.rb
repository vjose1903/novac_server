class TipoArticulosController < ApplicationController

  before_action :set_tipo_articulo, only: [ :show ]

  # GET /tipo_articulos
  def index
    if has_filter_target(params)
      resultado      = TipoArticulo.filtrar(params, get_parametros_opcionales)
      resultado.send_response self
    else
      return Response.new(params, nil, TipoArticulo.all.includes(TipoArticulo.models_includes), nil, { all: true }).send_response self
    end
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

  def get_parametros_opcionales
    return {
      all: params.has_key?(:all) ? params[:all] : true,
    }
  end

  private
  def set_tipo_articulo
    respuesta       = set_entidad(TipoArticulo, params, TipoArticulo.models_includes)
    @tipo_articulo  = respuesta.get_data

    return respuesta.send_response self if @tipo_articulo.nil?
  end
end
