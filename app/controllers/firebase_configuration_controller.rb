class FirebaseConfigurationController < ApplicationController
  skip_around_action :encarsular_usuario
  before_action :set_user_by_token
  before_action :require_authenticated_user
  skip_before_action :validateUserIsLogging!, only: :create_prelogin, raise: false
  skip_before_action :set_user_by_token, :require_authenticated_user, only: :create_prelogin

  def create
    data = update_configuration
    render json: { data: data }, status: :ok
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
      config_password: config_password
    )
    render json: { data: data }, status: :ok
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
    FirebaseConfigurationService.new.update(empresa_id: empresa_id, machine_id: machine_id, config: config, only_missing: only_missing)
  end

  def require_authenticated_user
    return if @resource.present?

    render json: { msg: 'Para realizar esta acción debe iniciar sesión.', action: 'close_session' }, status: :unauthorized
  end
end
