
require "fileutils"
require 'mime/types'

class Imagen < ApplicationRecord

  belongs_to :origen, polymorphic: true

    # ============================================================================================================================================

    def self.create_update_imagen(params, padre, is_save=false)
      res                       = Response.new

      imagen                    = Imagen.where(:id => params[:id]).first_or_create
      imagen_original           = imagen.attributes.with_indifferent_access unless params[:id].nil?

      imagen_info               = Imagen.saveFileInThisServer(params)

      imagen.file_name          = imagen_info[:file_name]
      imagen.base_64            = params[:base_64]
      imagen.file_hash          = imagen_info[:file_hash]
      imagen.origen             = padre

      imagen.valid?


      if imagen.errors.empty? && (!is_save || (is_save && imagen.save!))

        Imagen.removeFileInThisServer(imagen_original) unless params[:id].nil?
        res.set_data(imagen)
      else
        res.add_msgs(imagen.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      return res
    end

    # ============================================================================================================================================

    def self.removeFileInThisServer(imagen_original)

      existing_image = Imagen.where({file_hash: imagen_original[:file_hash]})

      if existing_image.empty?

        Dir.glob(Pathname.new(IMAGES_PATH).join('*.{jpg,jpeg,png,gif}')).each do | file_path |
          # Calcular el hash del archivo existente
          existing_image_data = File.read(file_path)
          existing_image_hash = Digest::SHA256.hexdigest(existing_image_data)

          # Comparar los hashes
          if existing_image_hash == imagen_original[:file_hash]
            FileUtils.remove_file(file_path)
          end
        end
      end

    end
    # ============================================================================================================================================

    def self.saveFileInThisServer(params)
      file_name      = params[:file_name]
      base64_string  = params[:base_64]


      FileUtils.mkdir_p(IMAGES_PATH) unless File.exist?(IMAGES_PATH)

      # Extraer la información de la imagen
      encoded_image  = base64_string.split(',')[1]
      image_data     = Base64.decode64(encoded_image)
      content_type   = base64_string.split(';')[0].split(':')[1]

      # Identificar la extensión de la imagen a partir del content_type
      extension      = MIME::Types[content_type].first.extensions.first

      # Calcular el hash de la nueva imagen
      new_image_hash = Digest::SHA256.hexdigest(image_data)

      # Comprobar si la imagen ya existe en el servidor
      existing_image = Imagen.find_by_file_hash(new_image_hash)

      if existing_image.nil?
        File.open(File.join(IMAGES_PATH, "#{file_name}.#{extension}"), 'wb') { | file | file.write image_data }
        return { file_name: "#{file_name}.#{extension}", file_hash: new_image_hash }.with_indifferent_access
      else
        return { file_name: existing_image.file_name, file_hash: existing_image.file_hash  }.with_indifferent_access
      end

    end

    # ============================================================================================================================================

    def self.validar_e_inicializar(items, padre, save)
      res_valid = Response.new
      array_valid=[]

      items.each do |item|
        res_temp = self.create_update_imagen(item, padre, !item[:id].nil?)

        if res_temp.status_valid
          array_valid.push(res_temp.get_data)
        else
          return res_temp
        end
      end

      res_valid.set_data array_valid
      return res_valid
    end
end
