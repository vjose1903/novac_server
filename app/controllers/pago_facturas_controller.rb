class PagoFacturasController < ApplicationController
  before_action :set_pago_factura, only: [:show, :destroy]


  # GET /pago_facturas
  def index
    return Response.new(params, nil, PagoFactura.where({estado: true}).order('id DESC'), nil, { all: true }).send_response self
  end

  # GET /pago_facturas/1
  def show
    return Response.new(params, nil, @pago_factura, nil, { all: true }).send_response self
  end

  def getPagosFiltrados
    arg = params["arg"]
    resultado = PagoFactura.filtrarPagos(arg, set_paginate_options(params))
    resultado.send_response self
  end

  def crear_actualizar_pago
    parametros = params
    parametros["id"] = params["id"] if params["id"]

    resultado = PagoFactura.create_update(parametros, true)
    resultado.send_response self
  end

  # POST /pago_facturas
  def create
    crear_actualizar_pago
  end

  # PATCH/PUT /pago_facturas/1
  def update
    crear_actualizar_pago
  end

	def revertirPagos
    resultado = PagoFactura.revertirPago(params)
    resultado.send_response self
  end

  # DELETE /pago_facturas/1
  def destroy
    resultado = borrar_entidad(@pago_factura)
    resultado.send_response self
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pago_factura
      respuesta = set_entidad(PagoFactura, params)
      @pago_factura = respuesta.get_data
      return respuesta.send_response self if @pago_factura.nil?
    end
end
