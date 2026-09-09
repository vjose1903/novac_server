class FirebaseConfigurationController < ApplicationController
  skip_around_action :encarsular_usuario
  before_action :set_user_by_token
  before_action :require_authenticated_user

  def create
    empresa_id = params.require(:empresa_id).to_s

    config = params.require(:config).permit!.to_h
    machine_id = params.require(:machine_id).to_s
    data = FirebaseConfigurationService.new.update(empresa_id: empresa_id, machine_id: machine_id, config: config)
    render json: { data: data }, status: :ok
  rescue ActionController::ParameterMissing, ArgumentError => e
    render json: { msg: e.message }, status: :unprocessable_entity
  rescue StandardError => e
    Rails.logger.error("Firebase configuration: #{e.full_message}")
    render json: { msg: 'No se pudo guardar la configuración en Firebase.' }, status: :bad_gateway
  end

  private

  def require_authenticated_user
    return if @resource.present?

    render json: { msg: 'Para realizar esta acción debe iniciar sesión.', action: 'close_session' }, status: :unauthorized
  end
end
