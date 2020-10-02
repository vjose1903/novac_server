class RecibosIngresosController < ApplicationController
  before_action :set_recibos_ingreso, only: [:show, :update, :destroy]

  # GET /recibos_ingresos
  def index
    @recibos_ingresos = RecibosIngreso.all
    recibos_ingresos = []

    @recibos_ingresos.each do |detalle|
      recibos_ingresos = RecibosIngreso.parsearData(detalle)
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
      @recibos_ingreso = RecibosIngreso.new(recibos_ingreso_params)
      @recibos_ingreso.numero_recibo = RecibosIngreso.find_secuencia

      if @recibos_ingreso.save
        unless SecuenciaIngreso.last.update({ secuencia: @recibos_ingreso.numero_recibo })
          render json: SecuenciaIngreso.last.errors, status: :unprocessable_entity
        else
          id = @recibos_ingreso.cliente_id
          total = @recibos_ingreso.total
          resultCliente = Cliente.CalculateBalanceCLiente(id, total, "-")

          if resultCliente[:error]
            render json: resultCliente, :status => resultCliente[:status]
            raise ActiveRecord::Rollback
          else
            continuar = CabeceraFactura.payFacturas(recibos_ingreso_params)
            unless continuar[:error]
              respuesta = @recibos_ingreso

              respuesta.cliente.balance = resultCliente[:balance]

              res = RecibosIngreso.parsearData(respuesta)

              puts res.to_json.yellow
              render json: res, status: :created, location: @recibos_ingreso
            else
              render json: continuar[:msg], status: :unprocessable_entity
              raise ActiveRecord::Rollback
            end
          end
        end
      else
        render json: @recibos_ingreso.errors, status: :unprocessable_entity
        raise ActiveRecord::Rollback
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
    params.fetch(:recibos_ingreso).permit(:user_id, :cliente_id, :total, :forma_pago, :tipo_recibo_id, :devuelta,
                                          detalle_recibos_attributes: [:recibos_ingreso_id, :cabecera_factura_id, :pago_total, :deposito, :descripcion, :pago_a_tiempo, :recibo])
  end
end
