class ImagenesController < ApplicationController
  before_action :set_imagen, only: [:show, :update, :destroy]

  # GET /imagenes
  def index
    @imagenes = Imagen.all

    render json: @imagenes
  end

  # GET /imagenes/1
  def show
    render json: @imagen
  end

  # POST /imagenes
  def create
    att = imagen_params

    att["path"] = Imagen.saveFileInThisServer(att[:fileName], att[:base_64])
    @imagen = Imagen.new(att)

    if @imagen.save
      render json: @imagen, status: :created, location: @imagen
    else
      render json: @imagen.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /imagenes/1
  def update
    if @imagen.update(imagen_params)
      render json: @imagen
    else
      render json: @imagen.errors, status: :unprocessable_entity
    end
  end

  # DELETE /imagenes/1
  def destroy
    @imagen.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_imagen
    @imagen = Imagen.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def imagen_params
    params.require(:imagen).permit(:fileName, :base_64, :path)
  end
end
