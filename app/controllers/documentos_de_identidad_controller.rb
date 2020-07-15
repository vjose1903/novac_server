class DocumentosDeIdentidadController < ApplicationController
  before_action :set_documento_de_identidad, only: [:show, :update, :destroy]

  # GET /documentos_de_identidad
  def index
    @documentos_de_identidad = DocumentoDeIdentidad.all

    render json: @documentos_de_identidad
  end

  # GET /documentos_de_identidad/1
  def show
    render json: @documento_de_identidad
  end

  # POST /documentos_de_identidad
  def create
    @documento_de_identidad = DocumentoDeIdentidad.new(documento_de_identidad_params)

    if @documento_de_identidad.save
      render json: @documento_de_identidad, status: :created, location: @documento_de_identidad
    else
      render json: @documento_de_identidad.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /documentos_de_identidad/1
  def update
    if @documento_de_identidad.update(documento_de_identidad_params)
      render json: @documento_de_identidad
    else
      render json: @documento_de_identidad.errors, status: :unprocessable_entity
    end
  end

  # DELETE /documentos_de_identidad/1
  def destroy
    @documento_de_identidad.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_documento_de_identidad
      @documento_de_identidad = DocumentoDeIdentidad.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def documento_de_identidad_params
      params.require(:documento_de_identidad).permit(:user_id, :suplidor_id, :cliente_id, :descripcion, :documento)
    end
end
