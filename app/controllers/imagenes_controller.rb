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

  # Serve the persisted file first and use the database copy as a fallback.
  def file
    imagen = Imagen.find_by(file_name: params[:file_name])
    return head :not_found unless imagen

    file_path = File.join(IMAGES_PATH, imagen.file_name)
    return send_file file_path, type: image_content_type(imagen.file_name), disposition: 'inline' if File.file?(file_path)

    if imagen.base_64.present?
      content_type, encoded_data = imagen.base_64.split(',', 2)
      return head :unprocessable_entity unless encoded_data.present?

      mime_type = content_type.to_s.delete_prefix('data:').split(';').first
      enqueue_file_restore(imagen)
      return send_data Base64.decode64(encoded_data), type: mime_type.presence || image_content_type(imagen.file_name)
    end

    head :not_found
  end

  # POST /imagenes
  def create
    att = imagen_params

    path = Imagen.saveFileInThisServer(att[:file_name], att[:base_64])
    att["path"] = path if Imagen.column_names.include?("path")
    att.delete("path") unless Imagen.column_names.include?("path")
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
    params.require(:imagen).permit(:file_name, :base_64, :path)
  end

  def image_content_type(file_name)
    MIME::Types.type_for(file_name).first&.content_type || 'application/octet-stream'
  end

  def enqueue_file_restore(imagen)
    RestoreImagenFileJob.perform_later(imagen.id)
  rescue StandardError => error
    Rails.logger.warn("No se pudo programar la restauración de la imagen #{imagen.id}: #{error.message}")
  end
end
