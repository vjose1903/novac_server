require 'json'
require 'uri'

# Fuente única de campos, ámbitos y tipos para Rails y el contrato distribuido a Electron.
class ConfigurationContract
  SCHEMA = JSON.parse(File.read(Rails.root.join('config/configuration_schema.json'))).freeze
  VERSION = SCHEMA.fetch('version')
  FIELDS = SCHEMA.fetch('fields').freeze
  LEGACY_METADATA = %w[id firebase_empresa_id firebase_config_missing firebase_config_needs_sync
    firebase_config_sync_patch firebase_logo_sync_keys firebase_sync_done operative_system printersList app_version
    logo_empresa logo_impresion firebase_general_revision firebase_machine_revision firebase_config_schema_version].freeze

  def self.values(config, scope: nil, strict: false)
    raise ArgumentError, 'Configuración inválida' unless config.is_a?(Hash)
    unknown = config.keys - FIELDS.keys - LEGACY_METADATA
    raise ArgumentError, "Parámetros de configuración desconocidos: #{unknown.join(', ')}" if strict && unknown.any?

    FIELDS.each_with_object({}) do |(key, rule), result|
      next if scope && rule['scope'] != scope
      next unless config.key?(key)
      value = config[key]
      valid = case rule['type']
              when 'boolean' then value == true || value == false
              when 'string' then value.is_a?(String) && value.length <= rule.fetch('maxLength')
              when 'stringMap'
                value.is_a?(Hash) && value.size <= 100 && value.all? do |name, item|
                  name.match?(/\A[a-zA-Z0-9_]+\z/) && !%w[__proto__ prototype constructor].include?(name) && item.is_a?(String) && item.length <= 4096
                end
              else false
              end
      valid &&= rule['enum'].include?(value) if rule['enum']
      if valid && rule['format'] == 'httpUrl' && value.present?
        begin
          uri = URI.parse(value)
          valid = %w[http https].include?(uri.scheme) && uri.host.present? && uri.userinfo.nil?
        rescue URI::InvalidURIError
          valid = false
        end
      end
      raise ArgumentError, "Valor inválido en configuración: #{key}" unless valid
      result[key] = value
    end
  end
end
