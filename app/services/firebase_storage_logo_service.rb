require 'base64'
require 'googleauth'
require 'json'
require 'net/http'
require 'securerandom'
require 'uri'

class FirebaseStorageLogoService
  STORAGE_SCOPE = 'https://www.googleapis.com/auth/devstorage.read_write'.freeze
  ALLOWED_KEYS = %w[logo_empresa logo_impresion].freeze
  MAX_BYTES = 5.megabytes

  def initialize
    @bucket = ENV.fetch('FIREBASE_STORAGE_BUCKET', 'novac-pc-configuration.firebasestorage.app')
    @credentials_path = ENV.fetch(
      'GOOGLE_APPLICATION_CREDENTIALS',
      Rails.root.join('secrets/firebase-service-account.json').to_s
    )
  end

  def upload(empresa_id:, key:, data_url:)
    raise ArgumentError, 'Empresa inválida' if empresa_id.blank?
    raise ArgumentError, 'Logo inválido' unless ALLOWED_KEYS.include?(key.to_s)

    content_type, encoded_data = data_url.to_s.split(',', 2)
    raise ArgumentError, 'El logo debe ser una imagen Base64' if encoded_data.blank? || !content_type.to_s.start_with?('data:image/')

    image_data = Base64.strict_decode64(encoded_data)
    raise ArgumentError, 'El logo supera el tamaño máximo permitido' if image_data.bytesize > MAX_BYTES

    object_name = "Empresas/#{empresa_id}/logos/#{key}"
    upload_object(object_name, image_data, content_type.delete_prefix('data:').split(';').first)
    object_name
  rescue ArgumentError, Google::Auth::AuthorizationError
    raise
  rescue StandardError => e
    raise "No se pudo subir #{key} a Firebase Storage: #{e.message}"
  end

  private

  def upload_object(object_name, image_data, content_type)
    credentials = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(@credentials_path),
      scope: STORAGE_SCOPE
    )
    credentials.fetch_access_token!

    boundary = "firebase-logo-#{SecureRandom.hex(12)}"
    metadata = { name: object_name, contentType: content_type }
    body = [
      "--#{boundary}\r\nContent-Type: application/json; charset=UTF-8\r\n\r\n",
      metadata.to_json,
      "\r\n--#{boundary}\r\nContent-Type: #{content_type}\r\n\r\n",
      image_data,
      "\r\n--#{boundary}--\r\n"
    ].join

    uri = URI("https://storage.googleapis.com/upload/storage/v1/b/#{URI.encode_www_form_component(@bucket)}/o?uploadType=multipart")
    uri.query = "uploadType=multipart&name=#{URI.encode_www_form_component(object_name)}"
    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Bearer #{credentials.access_token}"
    request['Content-Type'] = "multipart/related; boundary=#{boundary}"
    request.body = body

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
    return if response.is_a?(Net::HTTPSuccess)

    raise "Firebase Storage respondió #{response.code}: #{response.body.to_s[0, 500]}"
  end
end
