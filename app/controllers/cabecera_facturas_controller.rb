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

  def getGroup
    resultado = CabeceraFactura.get_group_facturas_by_id(params)
    resultado.send_response self
  end

  def getFacturasByParams
    resultado = CabeceraFactura.get_facturas_by_params(params, set_paginate_options(params))
    resultado.send_response self
  end

  def comprobarSerial
    resultado = CabeceraFactura.comprobar_serial(params)
    resultado.send_response self
  end

  def verificateCanUpdateById
    resultado = CabeceraFactura.verificateCanUpdate(params["id"])
    resultado.send_response self
  end

  def getViajesSinCompletar
    resultado = CabeceraFactura.get_viajes_by_completar(params, set_paginate_options(params))
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

  def deleteDocumentos
    resultado = CabeceraFactura.delete_documentos(params)
    resultado.send_response self
  end

  def get_parametros_opcionales
    return {
      actual_price:       params['actual_price']     || false,
      camiones_viajes:    params['camiones_viajes']  || false,
      movimientos_viaje:  params['movimientos_viaje']  || false,
      all: true
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
