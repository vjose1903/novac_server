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

      
      
      today_cuadre = CuadreCaja.where({ created_at: DateTime.now.beginning_of_day..DateTime.now.end_of_day})

      
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
            end
            # end
          end

          my_print_log(@recibos_ingreso.to_json)
          detalles = DetalleRecibo.CreateDetalleRecibo(@recibos_ingreso)

          my_print_log('________________________________________')
          my_print_log(detalles)

          
          if detalles[0][:error]
            render json: { msg: detalles[:msg], error: detalles.errors }, :status => :unprocessable_entity
            raise ActiveRecord::Rollback
          end
          
          if params["vehiculo_id"]
            vehiculo = Vehiculo.find_by_id(params["vehiculo_id"])

            unless vehiculo.update({ cantidad_viajes: vehiculo.cantidad_viajes + 1 })
              render json: vehiculo.errors, status: :unprocessable_entity
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

            render json: res, status: :created, location: @recibos_ingreso
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

  def revertirIngreso
    RecibosIngreso.transaction do
      id_ = params["id"]
      last_recibo_info = RecibosIngreso.get_last_recibo_of_cabecera_factura(id_)[0]

      if last_recibo_info["is_ultimo"]
        last_recibo = RecibosIngreso.find_by_id(last_recibo_info["recibos_ingreso_id"])

        last_recibo.detalle_recibos.each do |detalle|
          resultFactura = CabeceraFactura.find_by_id(detalle["cabecera_factura_id"])

          obj = { balance: detalle["balance_anterior_factura"] }

          if resultFactura.fecha_completada
            obj["fecha_completada"] = nil
          end

          if resultFactura.pagada
            obj["pagada"] = false
          end

          unless resultFactura.update(obj)
            render json: resultFactura.errors, status: 400
            raise ActiveRecord::Rollback
          end

          resultCliente = Cliente.CalculateBalanceCLiente(last_recibo["cliente_id"], detalle["deposito"], "+")

          if resultCliente[:error]
            render json: resultCliente, status: 400
            raise ActiveRecord::Rollback
          end
        end
        
        if last_recibo["vehiculo_id"]
          vehiculo = Vehiculo.find_by_id(last_recibo["vehiculo_id"])
          
          unless vehiculo.update({ cantidad_viajes: vehiculo.cantidad_viajes - 1 })
            render json: vehiculo.errors, status: :unprocessable_entity
            raise ActiveRecord::Rollback
          end
        end
        
        unless last_recibo.destroy
          render json: last_recibo.errors, status: 400
          raise ActiveRecord::Rollback
        end

        render json: { msg: "Ultima transacción revertica correctamente." }, status: 200
      else
        render json: { msg: "No se puede revertir esta transacción" }, status: 400
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
    params.fetch(:recibos_ingreso).permit(:user_id, :cliente_id, :chofer, :total, :forma_pago, :tipo_factura_id, :devuelta, :fecha_equivalente,
                                          :vehiculo_id, :incidencia,
                                          detalle_recibos_attributes: [:recibos_ingreso_id, :balance_anterior_factura, :balance_factura, :cabecera_factura_id, :pago_total, :deposito, :descripcion, :pago_a_tiempo, :recibo])
  end
end
