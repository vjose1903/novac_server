class SecuenciaComprobantesController < ApplicationController
  before_action :set_secuencia_comprobante, only: [:show, :destroy]

  # GET /secuencia_comprobantes
  def index
    return Response.new(params, nil, Cliente.all.order('id DESC'), nil, {all: true}).send_response self
  end

  # GET /secuencia_comprobantes/1
  def show
    return Response.new(params, nil, @secuencia_comprobante, nil, {all: true}).send_response self
  end

  def getSecuenciaComprobantesFiltrados
    arg               = params["arg"]
    resultado         = SecuenciaComprobante.filtrar_ncf(arg, parse_pagination_params(params))
    resultado.send_response self
  end

  def crear_actualizar_ncf
    resultado         = SecuenciaComprobante.create_update_ncf(params, true)
    resultado.send_response self
  end

  # POST /secuencia_comprobantes
  def create
    crear_actualizar_ncf
  end

  # PATCH/PUT /secuencia_comprobantes/1
  def update
    crear_actualizar_ncf
  end

  def getPaqueteRncByEstado
    resultado = SecuenciaComprobante.get_paquete_rnc_by_estado(params["id"], params["estado"])
    resultado.send_response self
  end

  def destroy
    res = Response.new(nil, HTTP_STATUS_CODE[:conflict])

    if @secuencia_comprobante.estado
      res.add_msg('Este paquete de comprobantes esta activo, no se puede eliminar.')
    elsif @secuencia_comprobante.usado
      res.add_msg('Este paquete de comprobantes ya está usado, no se puede eliminar.')
    else
      res = borrar_entidad(@secuencia_comprobante)
    end

    res.send_response self
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_secuencia_comprobante
    respuesta              = set_entidad(SecuenciaComprobante, params)
    @secuencia_comprobante = respuesta.get_data

    return respuesta.send_response self if @secuencia_comprobante.nil?
  end
end
