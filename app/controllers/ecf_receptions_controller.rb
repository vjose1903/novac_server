class EcfReceptionsController < ApplicationController
  before_action :set_ecf_reception, only: %i[ show update destroy ]

  # GET /ecf_receptions
  def index
    @ecf_receptions = EcfReception.all

    render json: @ecf_receptions
  end

  # GET /ecf_receptions/1
  def show
    render json: @ecf_reception
  end

  # POST /ecf_receptions
  def create
    @ecf_reception = EcfReception.new(ecf_reception_params)

    if @ecf_reception.save
      render json: @ecf_reception, status: :created, location: @ecf_reception
    else
      render json: @ecf_reception.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /ecf_receptions/1
  def update
    if @ecf_reception.update(ecf_reception_params)
      render json: @ecf_reception
    else
      render json: @ecf_reception.errors, status: :unprocessable_entity
    end
  end

  # DELETE /ecf_receptions/1
  def destroy
    @ecf_reception.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ecf_reception
      @ecf_reception = EcfReception.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def ecf_reception_params
      params.require(:ecf_reception).permit(:eNCF, :rnc_emisor, :rnc_comprador, :monto_total)
    end
end
