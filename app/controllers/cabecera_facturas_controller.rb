include ActionView::Helpers::NumberHelper

class CabeceraFacturasController < ApplicationController
  before_action :set_cabecera_factura, only: [:show, :update, :destroy, :remplace_encf]
  before_action :validate_date_dgii,   only: [:remplace_encf]
  before_action :validate_travel_invoice!, only: [:create, :update, :updateMovimientosViaje]
  # GET /cabecera_facturas
  def index
    optional_params = get_parametros_opcionales
    return Response.new(params, nil, CabeceraFactura.all.where({ estado: true}).order('id DESC'), nil, optional_params, CabeceraFactura.models_includes_for(optional_params)).send_response self
  end

  # GET /cabecera_facturas/1
  def show
    optional_params = get_parametros_opcionales
    return Response.new(params, nil, @cabecera_factura, nil, optional_params, CabeceraFactura.models_includes_for(optional_params)).send_response self
  end

  def custom_route
    resultado              = Response.new()
    ruta_complemento       = params[:ruta_complemento]

    case ruta_complemento
    when 'get_group'
      resultado = CabeceraFactura.get_group_facturas_by_id(params)
    when 'get_documentos'
      resultado = CabeceraFactura.get_facturas_by_params(params, set_paginate_options(params), get_parametros_opcionales)
    when 'viajes'
      resultado = CabeceraFactura.get_viajes_by_completar(params, set_paginate_options(params), get_parametros_opcionales)
    when 'comprobar_serial'
      resultado = CabeceraFactura.comprobar_serial(params)
    when 'can_update'
      resultado = CabeceraFactura.verificate_can_update_factura(params["id"])
    when 'delete'
      resultado = CabeceraFactura.delete_documentos(params)
    else
      resultado.add_msg('Ruta no encontrada.')
      resultado.set_status(HTTP_STATUS_CODE[:not_implemented])
    end

    resultado.send_response self
  end

  def remplace_encf
    resultado = CabeceraFactura.encf_remplace(@cabecera_factura)
    resultado.send_response self
  end

  def updateMovimientosViaje
		resultado = CabeceraFactura.update_movimientos_viaje(params)
		resultado.send_response self
	end

  def getFacturasByClienteIdAndEstado
    resultado = CabeceraFactura.get_facturas_by_cliente_id_and_estado(params, set_paginate_options(params))
    resultado.send_response self
  end

  # POST /cabecera_facturas
  def create
    resultado = CabeceraFactura.create_factura(params, true)
    resultado.send_response self
  end

  # PATCH /cabecera_facturas/1
  def update
    resultado = CabeceraFactura.updateFactura(params)
    resultado.send_response self
  end


  def get_parametros_opcionales
    return {
      all: true,
      actual_price:         validate_optional_param(params, 'actual_price') ?         params['actual_price'].to_boolean       : false,
      movimientos_viaje:    validate_optional_param(params, 'movimientos_viaje') ?    params['movimientos_viaje'].to_boolean  : false,
      marca_modelo_anio:    validate_optional_param(params, 'marca_modelo_anio') ?    params['marca_modelo_anio'].to_boolean  : false,
      articulo_in_detalle:  validate_optional_param(params, 'articulo_in_detalle') ?  params['articulo_in_detalle'].to_boolean  : false,
    }
  end

  private

  def validate_travel_invoice!
    return if FirebaseConfigurationService.travel_module_enabled?(params[:empresa_id].presence || request.headers['X-Empresa-Id'])
    return unless ActiveModel::Type::Boolean.new.cast(params[:is_viaje]) || params[:movimientos_viaje].present?

    render json: { msg: ['El módulo de viajes no está habilitado para este servidor.'] }, status: HTTP_STATUS_CODE[:forbidden]
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_cabecera_factura
    respuesta         = set_entidad(CabeceraFactura, params)
    @cabecera_factura = respuesta.get_data

    return respuesta.send_response self if @cabecera_factura.nil?
  end

  def validate_date_dgii
    dgii_cert_date = ENV['DGII_CERTIFICATION_DATE']

    if dgii_cert_date.nil?
      msg_error = 'Variable de entorno DGII_CERTIFICATION_DATE no configurada.'
      return Response.new(params, msg_error, nil, HTTP_STATUS_CODE[:internal_server_error]).send_response self
    end

    begin
      fecha_certificacion = Date.parse(dgii_cert_date)
      fecha_factura       = Date.parse(@cabecera_factura.fecha_equivalente.to_s)

      if fecha_factura < fecha_certificacion
        msg_error = 'Solo se pueden reemplazar facturas luego de la fecha de certificación con la dgii'
        return Response.new(params, msg_error, nil, HTTP_STATUS_CODE[:bad_request]).send_response self
      end
    rescue ArgumentError => e
      msg_error = 'Error al procesar las fechas: formato inválido'
      return Response.new(params, msg_error, nil, HTTP_STATUS_CODE[:bad_request]).send_response self
    end
  end

end
