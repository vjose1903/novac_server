class FirebaseConfigurationController < ApplicationController
  skip_around_action :encarsular_usuario
  before_action :set_user_by_token
  before_action :require_authenticated_user
  skip_before_action :validateUserIsLogging!, only: :create_prelogin, raise: false
  skip_before_action :set_user_by_token, :require_authenticated_user, only: :create_prelogin

  def create
    data = update_configuration
    render json: { data: data }, status: :ok
  rescue FirebaseConfigurationService::Conflict => e
    render json: { msg: e.message }, status: :conflict
  rescue ActionController::ParameterMissing, ArgumentError => e
    render json: { msg: e.message }, status: :unprocessable_entity
  rescue StandardError => e
    Rails.logger.error("Firebase configuration: #{e.full_message}")
    render json: { msg: 'No se pudo guardar la configuración en Firebase.' }, status: :bad_gateway
  end

  def create_prelogin
    empresa_id = params.require(:empresa_id).to_s
    machine_id = params.require(:machine_id).to_s
    config_password = params[:config_password].to_s
    config = params.require(:config).permit!.to_h
    data = FirebaseConfigurationService.new.update_prelogin(
      empresa_id: empresa_id,
      machine_id: machine_id,
      config: config,
      config_password: config_password,
      **configuration_options
    )
    render json: { data: data }, status: :ok
  rescue FirebaseConfigurationService::Conflict => e
    render json: { msg: e.message }, status: :conflict
  rescue ActionController::ParameterMissing, ArgumentError => e
    render json: { msg: e.message }, status: :unprocessable_entity
  rescue StandardError => e
    Rails.logger.error("Firebase configuration: #{e.full_message}")
    render json: { msg: 'No se pudo guardar la configuración en Firebase.' }, status: :bad_gateway
  end

  private

  def update_configuration
    empresa_id = params.require(:empresa_id).to_s
    config = params.require(:config).permit!.to_h
    machine_id = params.require(:machine_id).to_s
    only_missing = ActiveModel::Type::Boolean.new.cast(params[:only_missing])
    service = FirebaseConfigurationService.new
    service.authorize_prelogin!(empresa_id: empresa_id, config_password: params[:config_password].to_s)
    service.update(empresa_id: empresa_id, machine_id: machine_id, config: config, only_missing: only_missing, **configuration_options)
  end

  def configuration_options
    {
      schema_version: params[:schema_version],
      expected_general_revision: params[:expected_general_revision],
      expected_machine_revision: params[:expected_machine_revision]
    }
  end

  def require_authenticated_user
    return if @resource.present?

    render json: { msg: 'Para realizar esta acción debe iniciar sesión.', action: 'close_session' }, status: :unauthorized
  end
end
