class FirebaseLogosController < ApplicationController
  skip_around_action :encarsular_usuario
  before_action :set_user_by_token
  before_action :require_authenticated_user

  def create
    empresa_id = params.require(:empresa_id).to_s

    logos = params.require(:logos).permit(:logo_empresa, :logo_impresion)
    service = FirebaseStorageLogoService.new
    paths = {}

    %w[logo_empresa logo_impresion].each do |key|
      value = logos[key]
      paths["#{key}_path"] = service.upload(empresa_id: empresa_id, key: key, data_url: value) if value.present?
    end

    render json: { data: paths }, status: :ok
  rescue ActionController::ParameterMissing, ArgumentError => e
    render json: { msg: e.message }, status: :unprocessable_entity
  rescue StandardError => e
    Rails.logger.error("Firebase logos: #{e.full_message}")
    render json: { msg: 'No se pudieron guardar los logos.' }, status: :bad_gateway
  end

  private

  def require_authenticated_user
    return if @resource.present?

    render json: { msg: 'Para realizar esta acción debe iniciar sesión.', action: 'close_session' }, status: :unauthorized
  end
end
