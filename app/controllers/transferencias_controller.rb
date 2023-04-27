class TransferenciasController < ApplicationController
  before_action :set_transferencia, only:[ :show, :anularTransferencia ]

  # GET /transferencias
  def index
    return Response.new(params, nil, Transferencia.all.where({ estado: true}).order('id ASC').includes(Transferencia.models_includes), nil, { all: true }).send_response self
  end

  # GET /transferencias/1
  def show
    return Response.new(params, nil, @transferencia, nil, { all: true }).send_response self
  end

  def crear_actualizar_transferencia
    res = Transferencia.create_update_transferencia(params)
    res.send_response self
  end

  # POST /transferencias
  def create
    crear_actualizar_transferencia
  end

  # PATCH/PUT /transferencias/1
  def update
    crear_actualizar_transferencia
  end

  # DELETE /transferencias/anular/1
  def anularTransferencia
    resultado = @transferencia.anular_registro
    resultado.send_response self
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transferencia
      @transferencia = Transferencia.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def transferencia_params
      params.require(:transferencia).permit(:cuenta_bancaria_origen_id, :cuenta_bancaria_destino_id, :user_creador_id, :last_user_update_id, :user_anulador_id, :tipo, :tasa, :monto, :monto_local, :comentario, :nombre_banco_tercero, :cuenta_bancaria_tercero, :numero_referencia, :fecha_equivalente, :fecha_anulacion, :estado)
    end
end
