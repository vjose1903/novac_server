class TrabajosController < ApplicationController
  before_action :set_trabajo, only: [:show, :update, :destroy]

  # GET /trabajos
  def index
    @trabajos = Trabajo.all

    render json: @trabajos
  end

  # GET /trabajos/1
  def show
    render json: @trabajo
  end

  # POST /trabajos
  def create
    @trabajo = Trabajo.new(trabajo_params)

    if @trabajo.save
      render json: @trabajo, status: :created, location: @trabajo
    else
      render json: @trabajo.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /trabajos/1
  def update
    if @trabajo.update(trabajo_params)
      render json: @trabajo
    else
      render json: @trabajo.errors, status: :unprocessable_entity
    end
  end

  # DELETE /trabajos/1
  def destroy
    @trabajo.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_trabajo
      @trabajo = Trabajo.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def trabajo_params
      params.require(:trabajo).permit(:cliente_id, :tipo_trabajo, :marca_id, :modelo_id, :identificador, :tiene_bateria, :descripcion)
    end
end
