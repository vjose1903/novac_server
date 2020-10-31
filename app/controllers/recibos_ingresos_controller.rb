class RecibosIngresosController < ApplicationController
  before_action :set_recibos_ingreso, only: [:show, :update, :destroy]

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

  # POST /recibos_ingresos
  def create
    RecibosIngreso.transaction do
      att = recibos_ingreso_params
      @recibos_ingreso = RecibosIngreso.new(att)
      @recibos_ingreso.fecha_equivalente = att["fecha_equivalente"] ? att["fecha_equivalente"] : DateTime.now
      @recibos_ingreso.numero_recibo = RecibosIngreso.find_secuencia

      if @recibos_ingreso.save!
        actual_secuencia_recibo = SecuenciaFactura.find_by_tipo_factura_id(17)

        unless actual_secuencia_recibo.update({ secuencia: @recibos_ingreso.numero_recibo })
          render json: actual_secuencia_recibo.errors, status: :unprocessable_entity
        else
          detalles = DetalleRecibo.CreateDetalleRecibo(@recibos_ingreso)
          my_print_log("typeof ===> ", detalles.class)

          if detalles[0][:error]
            render json: { msg: detalles[:msg], error: detalles.errors }, :status => :unprocessable_entity
            raise ActiveRecord::Rollback
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

            puts res.to_json.yellow
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
    id_ = params["id"]
    last_recibo = RecibosIngreso.get_last_recibo_of_cabecera_factura(id_)[0]
    render json: last_recibo
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
                                          detalle_recibos_attributes: [:recibos_ingreso_id, :balance_anterior_factura, :balance_factura, :cabecera_factura_id, :pago_total, :deposito, :descripcion, :pago_a_tiempo, :recibo])
  end
end
