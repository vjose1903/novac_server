include ActionView::Helpers::NumberHelper

class CabeceraFacturasController < ApplicationController
  before_action :set_cabecera_factura, only: [:show, :update, :destroy]
  # GET /cabecera_facturas
  def index
    return Response.new(params, nil, CabeceraFactura.all.where({ estado: true}).order('id DESC'), nil, get_parametros_opcionales).send_response self
  end

  # GET /cabecera_facturas/1
  def show
    # resultado = CabeceraFactura.get_one_by_id(params)

    return Response.new(params, nil, @cabecera_factura, nil, get_parametros_opcionales).send_response self
  end

  def custom_route
    resultado              = Response.new()
    ruta_complemento       = params[:ruta_complemento]
    puts "ruta_complemento --> ".yellow + "#{ruta_complemento}"

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
      actual_price:       validate_optional_param(params, 'actual_price') ?       params['actual_price'].to_boolean       : false,
      movimientos_viaje:  validate_optional_param(params, 'movimientos_viaje') ?  params['movimientos_viaje'].to_boolean  : false,
      marca_modelo_anio:  validate_optional_param(params, 'marca_modelo_anio') ?  params['marca_modelo_anio'].to_boolean  : false,
    }
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_cabecera_factura
    respuesta = set_entidad(CabeceraFactura, params)
    @cabecera_factura = respuesta.get_data

    return respuesta.send_response self if @cabecera_factura.nil?
  end

end
