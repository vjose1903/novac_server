class EntidadCuentasContablesController < ApplicationController
  before_action :set_entidad_cuenta_contable, only: %i[ show update destroy ]

  # GET /entidad_cuentas_contables
  def index
    @entidad_cuentas_contables = EntidadCuentaContable.all

    render json: @entidad_cuentas_contables
  end

  # GET /entidad_cuentas_contables/1
  def show
    render json: @entidad_cuenta_contable
  end

  # POST /entidad_cuentas_contables
  def create
    @entidad_cuenta_contable = EntidadCuentaContable.new(entidad_cuenta_contable_params)

    if @entidad_cuenta_contable.save
      render json: @entidad_cuenta_contable, status: :created, location: @entidad_cuenta_contable
    else
      render json: @entidad_cuenta_contable.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /entidad_cuentas_contables/1
  def update
    if @entidad_cuenta_contable.update(entidad_cuenta_contable_params)
      render json: @entidad_cuenta_contable
    else
      render json: @entidad_cuenta_contable.errors, status: :unprocessable_entity
    end
  end

  # DELETE /entidad_cuentas_contables/1
  def destroy
    @entidad_cuenta_contable.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_entidad_cuenta_contable
      @entidad_cuenta_contable = EntidadCuentaContable.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def entidad_cuenta_contable_params
      params.require(:entidad_cuenta_contable).permit(:origen_entidad_id, :origen_entidad_type, :cuenta_contable_id, :key, :tipo_agrupacion_contable, :origen_categoria_id, :origen_categoria_type)
    end
end
