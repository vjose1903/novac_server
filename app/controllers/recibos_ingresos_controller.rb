class RecibosIngresosController < ApplicationController
  before_action :set_recibos_ingreso, only: [:show, :destroy]


  # GET /recibos_ingresos
  def index
    return Response.new(params, nil, RecibosIngreso.where({estado: true}).order('id DESC'), nil, get_parametros_opcionales).send_response self
  end

  # GET /recibos_ingresos/1
  def show
    return Response.new(params, nil, @recibos_ingreso, nil, get_parametros_opcionales).send_response self
  end


  def getRecibosFiltrados
    arg = params["arg"]
    resultado = RecibosIngreso.filtrarRecibos(arg, parse_pagination_params(params))
    resultado.send_response self
  end


  def crear_actualizar_recibo
		parametros = params
		parametros["id"] = params["id"] if params["id"]

    resultado = RecibosIngreso.create_update_recibo(parametros, true)
		resultado.send_response self
	end

  # POST /recibos_ingresos
  def create
    crear_actualizar_recibo
  end

  # PATCH/PUT /recibos_ingresos/1
  def update
    crear_actualizar_recibo
  end

  def revertirRecibos
    resultado = RecibosIngreso.revertirRecibo(params)
    resultado.send_response self
  end


  # DELETE /recibos_ingresos/1
  def destroy
    resultado = borrar_entidad(@recibos_ingreso)
    resultado.send_response self
  end

  private


  def get_parametros_opcionales
    return {
      all:                validate_optional_param(params, 'all') ?               params['all'].to_boolean :               false,
      user_id:            validate_optional_param(params, 'user_id') ?           params['user_id'].to_boolean :           false,
      cliente_id:         validate_optional_param(params, 'cliente_id') ?        params['cliente_id'].to_boolean :        false,
      total:              validate_optional_param(params, 'total') ?             params['total'].to_boolean :             false,
      forma_pago:         validate_optional_param(params, 'forma_pago') ?        params['forma_pago'].to_boolean :        false,
      tipo_factura_id:    validate_optional_param(params, 'tipo_factura_id') ?   params['tipo_factura_id'].to_boolean :   false,
      devuelta:           validate_optional_param(params, 'devuelta') ?          params['devuelta'].to_boolean :          false,
      fecha_equivalente:  validate_optional_param(params, 'fecha_equivalente') ? params['fecha_equivalente'].to_boolean : false,
      estado:             validate_optional_param(params, 'estado') ?            params['estado'].to_boolean :            false,
      incidencias:        validate_optional_param(params, 'incidencias') ?       params['incidencias'].to_boolean :       false,
      numero_recibo:      validate_optional_param(params, 'numero_recibo') ?     params['numero_recibo'].to_boolean :     false,
      cliente:            validate_optional_param(params, 'cliente') ?           params['cliente'].to_boolean :           false,
      user:               validate_optional_param(params, 'user') ?              params['user'].to_boolean :              false,
      detalle_recibos:    validate_optional_param(params, 'detalle_recibos') ?   params['detalle_recibos'].to_boolean :   false,
    }
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_recibos_ingreso
    respuesta = set_entidad(RecibosIngreso, params)
    @recibos_ingreso = respuesta.get_data
    return respuesta.send_response self if @recibos_ingreso.nil?
  end
end
