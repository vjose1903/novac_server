require 'googleauth'
require 'json'
require 'net/http'
require 'uri'
require 'active_support/security_utils'

class FirebaseConfigurationService
  GENERAL_KEYS = %w[
    cliente nombre_empresa rnc_empresa direccion_empresa telefono_empresa color_app
    url_servidor url_servidor_respaldo config_password usa_url_principal usa_facturas_externas
    is_produccion has_contabilidad calcular_itbis usa_mora is_db_local facturacion_editar_precio
    vende_sin_inventario use_ecf usa_modulo_viajes usa_facturacion_electronica documentos_a_imprimir serie_default medida_producto_terminado
    logo_empresa_path logo_impresion_path
  ].freeze
  MACHINE_KEYS = %w[machineId mode_app pages_sizes printer_selected].freeze
  SCOPE = 'https://www.googleapis.com/auth/datastore'.freeze
  TRAVEL_CACHE_TTL = 30
  @travel_cache = {}

  def self.travel_module_enabled?(empresa_id)
    return false if empresa_id.blank?

    cached = @travel_cache[empresa_id]
    return cached[:value] if cached && cached[:expires_at] > Time.now

    fields = new.read_document("Empresas/#{empresa_id}/general_configuration/app")
    raw_value = fields.dig('fields', 'usa_modulo_viajes', 'booleanValue')
    raw_value = fields.dig('fields', 'usa_modulo_viajes', 'stringValue') if raw_value.nil?
    value = ActiveModel::Type::Boolean.new.cast(raw_value)
    @travel_cache[empresa_id] = { value: value, expires_at: Time.now + TRAVEL_CACHE_TTL }
    value
  rescue StandardError => e
    Rails.logger.error("Firebase travel configuration: #{e.message}")
    false
  end

  def initialize
    @project_id = ENV.fetch('FIREBASE_PROJECT_ID', 'novac-pc-configuration')
    @credentials_path = ENV.fetch(
      'GOOGLE_APPLICATION_CREDENTIALS',
      Rails.root.join('secrets/firebase-service-account.json').to_s
    )
  end

  def update(empresa_id:, machine_id:, config:, only_missing: false)
    raise ArgumentError, 'Empresa inválida' if empresa_id.blank?
    raise ArgumentError, 'Máquina inválida' if machine_id.blank?

    general = select(config, GENERAL_KEYS)
    general_document_path = "Empresas/#{empresa_id}/general_configuration/app"
    existing_general = firestore_fields_to_hash(read_document(general_document_path)['fields'])
    usa_facturacion_electronica = general.fetch('usa_facturacion_electronica', existing_general['usa_facturacion_electronica'])
    force_normal_serie = usa_facturacion_electronica != true && existing_general['serie_default'] != 'normal'
    general['serie_default'] = 'normal' unless usa_facturacion_electronica == true
    machine = select(config, MACHINE_KEYS).merge('machineId' => machine_id)
    if only_missing && force_normal_serie
      patch_document(general_document_path, general.except('serie_default'), only_missing: true)
      patch_document(general_document_path, { 'serie_default' => 'normal' }, only_missing: false)
    else
      patch_document(general_document_path, general, only_missing: only_missing)
    end
    patch_document("Empresas/#{empresa_id}/configuration/#{machine_id}", machine, only_missing: only_missing)
    self.class.instance_variable_get(:@travel_cache)&.delete(empresa_id)
    { 'firebase_empresa_id' => empresa_id, 'machineId' => machine_id }
  end

  def update_prelogin(empresa_id:, machine_id:, config:, config_password:)
    authorize_prelogin!(empresa_id: empresa_id, config_password: config_password)
    update(empresa_id: empresa_id, machine_id: machine_id, config: config)
  end

  def authorize_prelogin!(empresa_id:, config_password:)
    return true if Rails.env.development?

    stored_password = firestore_fields_to_hash(
      read_document("Empresas/#{empresa_id}/general_configuration/app")['fields']
    )['config_password'].to_s
    supplied_password = config_password.to_s

    valid = stored_password.present? && supplied_password.present? &&
      stored_password.bytesize == supplied_password.bytesize &&
      ActiveSupport::SecurityUtils.secure_compare(stored_password, supplied_password)

    raise ArgumentError, 'La contraseña de configuración no es válida.' unless valid
  end

  def read_document(document_path)
    credentials = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(@credentials_path),
      scope: SCOPE
    )
    credentials.fetch_access_token!
    uri = URI("https://firestore.googleapis.com/v1/projects/#{@project_id}/databases/(default)/documents/#{document_path}")
    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "Bearer #{credentials.access_token}"
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
    return {} if response.code.to_i == 404
    return JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)

    raise "Firestore respondió #{response.code}: #{response.body.to_s[0, 500]}"
  end

  private

  def select(config, keys)
    keys.each_with_object({}) do |key, result|
      result[key] = config[key] if config.key?(key) && !config[key].nil?
    end
  end

  def firestore_value(value)
    case value
    when String then { 'stringValue' => value }
    when TrueClass, FalseClass then { 'booleanValue' => value }
    when Integer then { 'integerValue' => value.to_s }
    when Float then { 'doubleValue' => value }
    when Hash then { 'mapValue' => { 'fields' => value.transform_values { |item| firestore_value(item) } } }
    when Array then { 'arrayValue' => { 'values' => value.map { |item| firestore_value(item) } } }
    else { 'nullValue' => nil }
    end
  end

  def firestore_fields_to_hash(fields)
    fields.to_h.each_with_object({}) do |(key, value), result|
      result[key] = firestore_value_to_ruby(value)
    end
  end

  def firestore_value_to_ruby(value)
    return nil if value.nil?
    return value['stringValue'] if value.key?('stringValue')
    return value['booleanValue'] if value.key?('booleanValue')
    return value['integerValue'].to_i if value.key?('integerValue')
    return value['doubleValue'] if value.key?('doubleValue')
    return value['timestampValue'] if value.key?('timestampValue')
    return value['nullValue'] if value.key?('nullValue')
    return firestore_fields_to_hash(value.dig('mapValue', 'fields')) if value.key?('mapValue')
    return value.dig('arrayValue', 'values').to_a.map { |item| firestore_value_to_ruby(item) } if value.key?('arrayValue')

    nil
  end

  def merge_configuration(existing, incoming, only_missing: false)
    incoming.to_h.each_with_object(existing.to_h.dup) do |(key, value), result|
      unless result.key?(key)
        result[key] = value
        next
      end

      if result[key].is_a?(Hash) && value.is_a?(Hash)
        result[key] = merge_configuration(result[key], value, only_missing: only_missing)
      elsif !only_missing
        result[key] = value
      end
    end
  end

  def patch_document(document_path, data, only_missing: false)
    existing_document = read_document(document_path)
    existing_fields = firestore_fields_to_hash(existing_document['fields'])
    merged_data = merge_configuration(existing_fields, data, only_missing: only_missing)

    credentials = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(@credentials_path),
      scope: SCOPE
    )
    credentials.fetch_access_token!
    uri = URI("https://firestore.googleapis.com/v1/projects/#{@project_id}/databases/(default)/documents/#{document_path}")
    request = Net::HTTP::Patch.new(uri)
    request['Authorization'] = "Bearer #{credentials.access_token}"
    request['Content-Type'] = 'application/json'
    request.body = JSON.generate('fields' => merged_data.transform_values { |value| firestore_value(value) })
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
    return if response.is_a?(Net::HTTPSuccess)

    raise "Firestore respondió #{response.code}: #{response.body.to_s[0, 500]}"
  end
end
