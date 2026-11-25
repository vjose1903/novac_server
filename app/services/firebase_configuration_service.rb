require 'googleauth'
require 'json'
require 'securerandom'
require 'net/http'
require 'uri'
require 'active_support/security_utils'

class FirebaseConfigurationService
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

  class Conflict < StandardError; end

  def update(empresa_id:, machine_id:, config:, only_missing: false, expected_general_revision: nil, expected_machine_revision: nil, schema_version: nil)
    [empresa_id, machine_id].each do |id|
      raise ArgumentError, 'Identificador de configuración inválido' unless id.is_a?(String) && id.match?(/\A[a-zA-Z0-9_-]{1,128}\z/)
    end
    if schema_version != ConfigurationContract::VERSION
      raise ArgumentError, 'El contrato de configuración cambió; actualice la aplicación.'
    end
    unless [expected_general_revision, expected_machine_revision].all? { |value| value.is_a?(String) && value.length <= 128 }
      raise ArgumentError, 'Falta la revisión de configuración. Recargue la aplicación.'
    end
    incoming = ConfigurationContract.values(config, strict: true)
    %w[logo_empresa logo_impresion].each do |key|
      value = incoming["#{key}_path"]
      if value && value != "Empresas/#{empresa_id}/logos/#{key}"
        raise ArgumentError, 'La ruta del logo no pertenece a la empresa.'
      end
    end
    general_path = "Empresas/#{empresa_id}/general_configuration/app"
    machine_path = "Empresas/#{empresa_id}/configuration/#{machine_id}"
    general_document = read_document(general_path)
    machine_document = read_document(machine_path)
    existing_general = firestore_fields_to_hash(general_document['fields'])
    existing_machine = firestore_fields_to_hash(machine_document['fields'])
    [existing_general, existing_machine].each do |existing|
      version = existing['_config_schema_version']
      if version && (!version.is_a?(Integer) || version < 1 || version > ConfigurationContract::VERSION)
        raise ArgumentError, 'La configuración requiere actualizar el servidor.'
      end
    end
    [[expected_general_revision, existing_general], [expected_machine_revision, existing_machine]].each do |expected, existing|
      if !expected.nil? && expected != existing.fetch('_config_revision', '')
        raise Conflict, 'La configuración cambió en otro equipo. Recargue antes de guardar.'
      end
    end
    general = merge_configuration(ConfigurationContract.values(existing_general, scope: 'general'), ConfigurationContract.values(incoming, scope: 'general'), only_missing: only_missing)
    machine = merge_configuration(ConfigurationContract.values(existing_machine, scope: 'machine'), ConfigurationContract.values(incoming, scope: 'machine'), only_missing: only_missing).merge('machineId' => machine_id)
    general['serie_default'] = 'normal' unless general['usa_facturacion_electronica'] == true
    revision = SecureRandom.uuid
    metadata = { '_config_schema_version' => ConfigurationContract::VERSION, '_config_revision' => revision }
    # Una sola operación atómica; las precondiciones evitan perder cambios concurrentes.
    writes = [[general_path, general_document, general], [machine_path, machine_document, machine]].map do |path, document, values|
      payload = values.merge(metadata)
      {
        update: { name: "projects/#{@project_id}/databases/(default)/documents/#{path}", fields: payload.transform_values { |value| firestore_value(value) } },
        updateMask: { fieldPaths: payload.keys },
        currentDocument: document['updateTime'] ? { updateTime: document['updateTime'] } : { exists: false }
      }
    end
    commit_configuration(writes)
    self.class.instance_variable_get(:@travel_cache)&.delete(empresa_id)
    # Nunca devolver config_password en la respuesta, aunque el cliente lo envíe
    # para autorizar el guardado.
    general.except('config_password').merge(machine).merge(
      'firebase_empresa_id' => empresa_id,
      'firebase_general_revision' => revision,
      'firebase_machine_revision' => revision,
      'firebase_config_schema_version' => ConfigurationContract::VERSION
    )
  end

  def update_prelogin(empresa_id:, machine_id:, config:, config_password:, **options)
    authorize_prelogin!(empresa_id: empresa_id, config_password: config_password)
    update(empresa_id: empresa_id, machine_id: machine_id, config: config, **options)
  end

  def authorize_prelogin!(empresa_id:, config_password:)
    raise ArgumentError, 'Empresa inválida' unless empresa_id.match?(/\A[a-zA-Z0-9_-]{1,128}\z/)

    document = read_document("Empresas/#{empresa_id}/general_configuration/app")
    stored_password = firestore_fields_to_hash(document['fields'])['config_password'].to_s
    if document.empty? && empresa_id == ENV['FIREBASE_BOOTSTRAP_EMPRESA_ID']
      stored_password = ENV['FIREBASE_BOOTSTRAP_CONFIG_PASSWORD'].to_s
    end
    supplied_password = config_password.to_s

    valid = stored_password.present? && supplied_password.present? &&
      stored_password.bytesize == supplied_password.bytesize &&
      ActiveSupport::SecurityUtils.secure_compare(stored_password, supplied_password)

    raise ArgumentError, 'La contraseña de configuración no es válida.' unless valid
  end

  def read_document(document_path)
    uri = URI("https://firestore.googleapis.com/v1/projects/#{@project_id}/databases/(default)/documents/#{document_path}")
    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "Bearer #{access_token}"
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, open_timeout: 10, read_timeout: 20) { |http| http.request(request) }
    return {} if response.code.to_i == 404
    return JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)

    raise "Firestore respondió #{response.code}: #{response.body.to_s[0, 500]}"
  end

  private

  def access_token
    @access_token ||= File.open(@credentials_path) do |file|
      credentials = Google::Auth::ServiceAccountCredentials.make_creds(json_key_io: file, scope: SCOPE)
      credentials.fetch_access_token!
      credentials.access_token
    end
  end

  def commit_configuration(writes)
    uri = URI("https://firestore.googleapis.com/v1/projects/#{@project_id}/databases/(default)/documents:commit")
    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Bearer #{access_token}"
    request['Content-Type'] = 'application/json'
    request.body = JSON.generate(writes: writes)
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, open_timeout: 10, read_timeout: 20) { |http| http.request(request) }
    raise Conflict, 'La configuración cambió durante el guardado. Recargue e intente de nuevo.' if [409, 412].include?(response.code.to_i) || response.body.to_s.include?('FAILED_PRECONDITION')
    raise "No se pudo confirmar la configuración (#{response.code})" unless response.is_a?(Net::HTTPSuccess)
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

end
