class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  # protect_from_forgery with: :exception
  # if ENV["RAILS_ENV"] == "development"
  #   # :except => [:comprobar, :notificar_version_descargada, :rapidita_apk ] ,
  # end
  before_action :configure_permitted_parameters, if: :devise_controller?
  # before_action :authenticate_user!, unless: :devise_controller?

  before_action :validateUserIsLogging!, unless: :devise_controller?

  protected

  def validateUserIsLogging!
    unless user_signed_in?
      render json: { error: "Debe de estar autenticado para realizar esta accion." }, status: Rack::Utils::SYMBOL_TO_STATUS_CODE[:unauthorized]
      # render json: { error: "Debe de estar autenticado para realizar esta accion." }, status: 403
    end
  end

  def configure_permitted_parameters
    permits = [:nombre, :usuario, :estado, :cedula, :apellido, :sexo, :fotoPerfil, :fotoPerfil_cache, :telefono, :email, :fecha_nacimiento, :role, :password, :password_confirmation, :registration,
               imagen_attributes: [:file_name, :base_64, :path],
               documentos_de_identidad_attributes: [:user_id, :descripcion, :documento, :principal]]

    devise_parameter_sanitizer.permit(:sign_up, keys: permits)

    devise_parameter_sanitizer.permit(:sessions, keys: permits)

    devise_parameter_sanitizer.permit(:sign_in, keys: permits)

    devise_parameter_sanitizer.permit(:account_update, keys: permits)
  end
end
