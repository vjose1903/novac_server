class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  # protect_from_forgery with: :exception
  if ENV["RAILS_ENV"] == "development"
    # :except => [:comprobar, :notificar_version_descargada, :rapidita_apk ] ,
    # before_action :authenticate_user!, unless: :devise_controller?
  end
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    permits = [:nombre, :usuario, :estado, :cedula, :apellido, :sexo, :fotoPerfil, :fotoPerfil_cache, :telefono, :email, :fecha_nacimiento, :role, :password, :password_confirmation, :registration,
               imagen_attributes: [:fileName, :base_64, :path],
               documentos_de_identidad_attributes: [:user_id, :descripcion, :documento, :principal]]

    devise_parameter_sanitizer.permit(:sign_up, keys: permits)

    devise_parameter_sanitizer.permit(:sessions, keys: permits)

    devise_parameter_sanitizer.permit(:sign_in, keys: permits)

    devise_parameter_sanitizer.permit(:account_update, keys: permits)
  end
end
