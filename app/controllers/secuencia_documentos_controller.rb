class SecuenciaDocumentosController < ApplicationController
  before_action :set_secuencia_documento, only: %i[ show update aumentar_secuencia ]
  before_action :get_origin_secuencia, only: %i[ update ]

  # GET /secuencia_documentos
  def index
    return Response.new(params, nil, SecuenciaDocumento.all.where({ estado: STATUS.active }).order('id DESC'), nil, { all: true }).send_response self
  end

  # GET /secuencia_documentos/1
  def show
    return Response.new(params, nil, @secuencia_documento, nil, { all: true }).send_response self
  end

  # PATCH/PUT /secuencia_documentos/1
  def update
    resultado = SecuenciaDocumento.manage_secuencia(params, @origin_secuencia, true)
    resultado.send_response self
  end

  private
    def set_secuencia_documento
      respuesta = set_entidad(SecuenciaDocumento, params)
      @secuencia_documento  = respuesta.get_data

      return respuesta.send_response self if @secuencia_documento.nil?
    end

    def get_origin_secuencia
      @origin_secuencia  = fetch_related_object(@secuencia_documento, 'origin_secuencia')
      return Response.new(params, HTTP_STATUS.not_found, nil, "Error en la obtención del registro relacionado con esta secuencia, Por favor comunicarse con el soporte de Novac System", nil).send_response self  if @origin_secuencia.nil?
    end
end
