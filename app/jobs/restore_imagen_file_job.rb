require 'base64'
require 'fileutils'
require 'tempfile'

class RestoreImagenFileJob < ApplicationJob
  queue_as :default

  def perform(imagen_id)
    imagen = Imagen.find_by(id: imagen_id)
    return unless imagen&.base_64.present?

    file_name = File.basename(imagen.file_name.to_s)
    return if file_name.blank? || file_name != imagen.file_name

    FileUtils.mkdir_p(IMAGES_PATH)
    file_path = File.join(IMAGES_PATH, file_name)
    return if File.file?(file_path)

    _, encoded_data = imagen.base_64.split(',', 2)
    return if encoded_data.blank?

    Tempfile.create(['imagen-', File.extname(file_name)], IMAGES_PATH) do |temporary_file|
      temporary_file.binmode
      temporary_file.write(Base64.decode64(encoded_data))
      temporary_file.flush
      FileUtils.mv(temporary_file.path, file_path) unless File.file?(file_path)
    end
  rescue StandardError => error
    Rails.logger.warn("No se pudo recrear la imagen #{imagen_id}: #{error.message}")
  end
end
