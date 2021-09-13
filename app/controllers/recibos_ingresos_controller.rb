class RecibosIngresosController < ApplicationController
  before_action :set_recibos_ingreso, only: [:show, :update, :destroy]
  before_action :set_last_recibo_no_ultimo, only: [:create]

  # GET /recibos_ingresos
  def index
    @recibos_ingresos = RecibosIngreso.all
    recibos_ingresos = []

    @recibos_ingresos.each do |detalle|
      recibos_ingresos.push(RecibosIngreso.parsearData(detalle))
    end

    render json: recibos_ingresos
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
    # arg = params["arg"]
    # page = params["page"]
    # per_page = params["per_page"]
    # paginado = params["paginado"] === "true" ? true : false

    # recibos_ = []
    # recibos = RecibosIngreso.filtrarRecibos(arg)

    # recibos.each do |item|
    #   recibo = RecibosIngreso.find_by_id(item["id"])
    #   recibos_.push(RecibosIngreso.parsearData(recibo))
    # end

    # res = []

    # if paginado
    #   res = recibos_.to_a.my_paginate(page, per_page)
    # else
    #   res = recibos_
    # end

    # render json: res
  end
  
  # GET /recibos_ingresos/1
  def show
    render json: @recibos_ingreso
  end

  def set_last_recibo_no_ultimo
    params["detalle_recibos_attributes"].each_with_index do |d, idx|
      last_pago_info = RecibosIngreso.get_last_recibo_of_cabecera_factura(d["cabecera_factura_id"])[0]

      if last_pago_info
        ultimo_pago = DetalleRecibo.find_by_id(last_pago_info["id"])

        unless ultimo_pago.update({ is_ultimo: false })
          return [{ error: true, msg: ultimo_pago.errors, status: :unprocessable_entity }]
        end
      end
    end
  end

  # POST /recibos_ingresos
  def create
    RecibosIngreso.transaction do
      att = recibos_ingreso_params

      existe_incidencia = false
      if params["incidencia"]
        @incidencia = Incidencia.new(att["incidencia"])
        existe_incidencia = true
      end

      att.except(:incidencia)
      @recibos_ingreso = RecibosIngreso.new(att)

      today_cuadre = CuadreCaja.where({ fecha_equivalente: DateTime.now.beginning_of_day..DateTime.now.end_of_day})
      
      if today_cuadre.empty?
        @recibos_ingreso.fecha_equivalente = att["fecha_equivalente"] ? att["fecha_equivalente"] : DateTime.now
      else
        @recibos_ingreso.fecha_equivalente = att["fecha_equivalente"] ? att["fecha_equivalente"] : CabeceraFactura.calculateNextDay
      end

      @recibos_ingreso.numero_recibo = RecibosIngreso.find_secuencia

      if @recibos_ingreso.save!
        actual_secuencia_recibo = SecuenciaFactura.find_by_tipo_factura_id(17)

        unless actual_secuencia_recibo.update({ secuencia: @recibos_ingreso.numero_recibo })
          render json: actual_secuencia_recibo.errors, status: :unprocessable_entity
        else
          if existe_incidencia
            # incidencia_ = Incidencia.find_by_id(@incidencia["id"])
            # if incidencia_
            #   unless incidencia_.save!
            #     render json: incidencia_.errors, status: :unprocessable_entity
            #   end
            # else
            unless @incidencia.save!
              render json: @incidencia.errors, status: :unprocessable_entity
              raise ActiveRecord::Rollback
            end
            # end
          end

          detalles = DetalleRecibo.CreateDetalleRecibo(@recibos_ingreso)
          
          if detalles[0][:error]
            render json: { msg: detalles[0][:msg] }, :status => :unprocessable_entity
            raise ActiveRecord::Rollback
          end
          
          if params["vehiculo_id"]
            vehiculo = Vehiculo.find_by_id(params["vehiculo_id"])
            
            unless vehiculo.update({ cantidad_viajes: vehiculo.cantidad_viajes + 1 })
              render json: vehiculo.errors, status: :unprocessable_entity
              raise ActiveRecord::Rollback
            end
          end
          
          
          @recibos_ingreso.detalle_recibos = detalles
          
          unless @recibos_ingreso.save!
            render json: @recibos_ingreso.errors, :status => :unprocessable_entity
            raise ActiveRecord::Rollback
          end

          continuar = CabeceraFactura.payFacturas(recibos_ingreso_params)
          unless continuar[:error]
            respuesta = @recibos_ingreso

            respuesta.cliente.balance = Cliente.find_by_id(@recibos_ingreso.cliente_id).balance
            res = RecibosIngreso.parsearData(respuesta)
            
            puts "res ==> ". red + "#{res.to_json}"

            render json: res.to_json, status: :created, location: @recibos_ingreso
          else
            render json: continuar[:msg], status: :unprocessable_entity
            raise ActiveRecord::Rollback
          end
        end
      else
        render json: @recibos_ingreso.errors, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end
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

  # Use callbacks to share common setup or constraints between actions.
  def set_recibos_ingreso
    @recibos_ingreso = RecibosIngreso.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def recibos_ingreso_params
    params.fetch(:recibos_ingreso).permit(:user_id, :cliente_id, :chofer, :total, :forma_pago, :tipo_factura_id, :devuelta, :fecha_equivalente, :estado,
                                          :vehiculo_id, :incidencia, :numero_recibo,
                                          detalle_recibos_attributes: [:recibos_ingreso_id, :balance_anterior_factura, :balance_factura, :cabecera_factura_id, :pago_total, :deposito, :descripcion, :pago_a_tiempo, :recibo])
  end
end
