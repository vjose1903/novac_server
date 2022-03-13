class NotasController < ApplicationController
  before_action :set_nota, only: [:show, :update, :destroy]

  # GET /notas
  def index
    @notas = Nota.all

    render json: @notas
  end

  # GET /notas/1
  def show
    render json: @nota
  end

  # POST /notas
  def create
    @nota = Nota.new(nota_params)

    if @nota.save
      render json: @nota, status: :created, location: @nota
    else
      render json: @nota.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /notas/1
  def update
    if @nota.update(nota_params)
      render json: @nota
    else
      render json: @nota.errors, status: :unprocessable_entity
    end
  end

  # DELETE /notas/1
  def destroy
    @nota.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_nota
      @nota = Nota.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def nota_params
      params.require(:nota).permit(:cliente_id, :user_id, :tipo_factura_id, :total, :identificador, :numero_documento, :numero_comprobante, :fecha_equivalente, :estado)
    end
end
