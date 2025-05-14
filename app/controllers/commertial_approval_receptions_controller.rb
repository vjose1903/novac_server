class CommertialApprovalReceptionsController < ApplicationController
  before_action :set_commertial_approval_reception, only: %i[ show update destroy ]

  # GET /commertial_approval_receptions
  def index
    @commertial_approval_receptions = CommertialApprovalReception.all

    render json: @commertial_approval_receptions
  end

  # GET /commertial_approval_receptions/1
  def show
    render json: @commertial_approval_reception
  end

  # POST /commertial_approval_receptions
  def create
    @commertial_approval_reception = CommertialApprovalReception.new(commertial_approval_reception_params)

    if @commertial_approval_reception.save
      render json: @commertial_approval_reception, status: :created, location: @commertial_approval_reception
    else
      render json: @commertial_approval_reception.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /commertial_approval_receptions/1
  def update
    if @commertial_approval_reception.update(commertial_approval_reception_params)
      render json: @commertial_approval_reception
    else
      render json: @commertial_approval_reception.errors, status: :unprocessable_entity
    end
  end

  # DELETE /commertial_approval_receptions/1
  def destroy
    @commertial_approval_reception.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_commertial_approval_reception
      @commertial_approval_reception = CommertialApprovalReception.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def commertial_approval_reception_params
      params.require(:commertial_approval_reception).permit(:eNCF, :rnc_emisor, :rnc_comprador, :monto_total, :estado, :detalleMotivoRechazo, :cabecera_factura_id)
    end
end
