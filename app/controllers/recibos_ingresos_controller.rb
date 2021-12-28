class RecibosIngresosController < ApplicationController
  before_action :set_recibos_ingreso, only: [:show, :update, :destroy]


  # GET /recibos_ingresos
  def index
    return Response.new(params, nil, RecibosIngreso.where({estado: true}).order('id DESC'), nil, get_parametros_opcionales).send_response self
  end

  # GET /recibos_ingresos/1
  def show
    return Response.new(params, nil, @recibos_ingreso, nil, get_parametros_opcionales).send_response self
  end

  def getRecibosLimit
    cant = params["cant"]
    recibos = []
    recibos_temp = RecibosIngreso.get_last_recibos(cant)
    
    recibos_temp.each do |item|
      recibos.push(RecibosIngreso.parsearData(item))
    end
    render json: recibos
  end
  

  
  def getRecibosFiltrados
    arg = params["arg"]
    resultado = RecibosIngreso.filtrarRecibos(arg, set_paginate_options(params))
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

  def revertirRecibos
    RecibosIngreso.transaction do
      id_ = params["id"]
      tipo_ = params["tipo"]

      puede_continuar = false
      
      if tipo_ ==='by_factura'
        last_recibo_info = RecibosIngreso.get_last_recibo_of_cabecera_factura(id_)[0]
        
        if last_recibo_info["is_ultimo"]
          puede_continuar = true
        end
      else
        puede_continuar = true
      end

      if puede_continuar
        recibo_id = tipo_ === "by_factura" ? last_recibo_info["recibos_ingreso_id"] : id_
        
        revertirResponse = RecibosIngreso.procesoRevertirRecibo(recibo_id)
        
        if revertirResponse[:error]
          render json: revertirResponse, status: 400
          raise ActiveRecord::Rollback
        end
  
        msg = tipo_ === "by_factura" ? "Ultima transacción revertida correctamente." : "Recibo de ingreso anulado correctamente."
        
        render json: { msg: msg }, status: 200
      else
        msg_ = tipo_ === "by_factura" ? "No se puede revertir esta transacción." : "Error anulando Recibo de ingreso."
        render json: { msg: msg_ }, status: 400
      end
    end
  end

  # PATCH/PUT /recibos_ingresos/1
  def update
    if @recibos_ingreso.update(recibos_ingreso_params)
      render json: @recibos_ingreso
    else
      render json: @recibos_ingreso.errors, status: :unprocessable_entity
    end
  end

  # DELETE /recibos_ingresos/1
  def destroy
    @recibos_ingreso.destroy
  end

  private


  def get_parametros_opcionales 
    return {
      all:                 params['all'] || false,
      user_id:             params['user_id'] ||false,
      cliente_id:          params['cliente_id'] ||false,
      total:               params['total'] ||false,
      forma_pago:          params['forma_pago'] ||false,
      tipo_factura_id:     params['tipo_factura_id'] ||false,
      devuelta:            params['devuelta'] ||false,
      fecha_equivalente:   params['fecha_equivalente'] ||false,
      estado:              params['estado'] ||false,
      vehiculo_id:         params['vehiculo_id'] ||false,
      incidencias:         params['incidencias'] ||false,
      numero_recibo:       params['numero_recibo'] ||false,
      detalle_recibos:     params['detalle_recibos'] ||false,
      chofer:              params['chofer'] ||false,
      cliente:             params['cliente'] ||false,
      user:                params['user'] ||false,
      detalle_recibos:     params['detalle_recibos'] ||false,
    }
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_recibos_ingreso
    respuesta = set_entidad(RecibosIngreso, params)
    @recibos_ingreso = respuesta.get_data
    return respuesta.send_response self if @recibos_ingreso.nil?
  end

  # Only allow a trusted parameter "white list" through.
  def recibos_ingreso_params
    params.fetch(:recibos_ingreso).permit(:user_id, :cliente_id, :chofer, :total, :forma_pago, :tipo_factura_id, :devuelta, :fecha_equivalente, :estado,
                                          :vehiculo_id, :incidencia, :numero_recibo,
                                          detalle_recibos_attributes: [:recibos_ingreso_id, :balance_anterior_factura, :balance_factura, :cabecera_factura_id, :pago_total, :deposito, :descripcion, :pago_a_tiempo, :recibo])
  end
end
