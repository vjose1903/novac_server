class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  # protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  if ENV["RAILS_ENV"] != "development"
    before_action :validateUserIsLogging!
  end

  around_action :encarsular_usuario

  def validateUserIsLogging!
    unless user_signed_in?
      render json: { msg: "Para realizar esta accion debe de iniciar sesión.", action: "close_session" }, status: HTTP_STATUS_CODE[:unauthorized] unless params["controller"] == "devise_token_auth/sessions"
    end
  end

  def encarsular_usuario
    Thread.current[:current_user] = current_user
    begin
      yield
    ensure
      Thread.current[:current_user] = nil
    end
  end

  def testFunction

    res = Response.new
    # user_id                  = get_current_user[:id]
    # result = Permiso.verificateUserPermiso(user_id, 'pre_venta')
    # result = Permiso.verificateUserPermiso(user_id, 'articulo')
    # result = Permiso.verificateUserPermiso(user_id, 'marca')

    # certification_params = { TipoeCF: 34, numero_comprobante: 'E340000000006' }.with_indifferent_access
    # document      = Nota.find_by_id(51)

    certification_params = { TipoeCF: 31, numero_comprobante: 'E310000000015' }.with_indifferent_access
    document        = CabeceraFactura.find_by_id(528)

    document_parsed = DGII_MANAGER.send(document, certification_params)

    res.set_data(document_parsed)

    res.send_response self

  end

  def testFunction_
    res = Response.new

    res.send_response self
  end

  # ============================================================================================
  # GET PERSONAS OF DOCUMENTO
  # ============================================================================================
  def getPersonasOfDocumento()
    res = Response.new
    filter_key = params["filter_key"]
    filter_value = params["filter_value"]

    documentos = DocumentoDeIdentidad.where("documento='#{filter_value}'")
    res.set_data(documentos, {persona: true})
    return res.send_response self
  end

  protected

  def configure_permitted_parameters
    permits = [:id, :nombre, :usuario, :estado, :cedula, :apellido, :sexo, :fotoPerfil, :fotoPerfil_cache, :telefono, :email, :fecha_nacimiento, :role, :password,
               :password_confirmation,
               imagen_attributes: [:file_name, :base_64, :path],
               documentos_de_identidad_attributes: [:user_id, :descripcion, :documento, :principal]]

    devise_parameter_sanitizer.permit(:sign_up, keys: permits)

    devise_parameter_sanitizer.permit(:sessions, keys: permits)

    devise_parameter_sanitizer.permit(:sign_in, keys: permits)

    devise_parameter_sanitizer.permit(:account_update, keys: permits)
  end


end
