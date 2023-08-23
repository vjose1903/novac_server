class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  # protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  # if ENV["RAILS_ENV"] != "development"
    before_action :validateUserIsLogging!
  # end

  around_action :encarsular_variables

  def validateUserIsLogging!
    unless user_signed_in?
      render json: { msg: "Para realizar esta accion debe de iniciar sesión.", action: "close_session" }, status: HTTP_STATUS_CODE[:unauthorized] unless params["controller"] == "devise_token_auth/sessions"
    end
  end

  def encarsular_variables
    Thread.current[:current_user]       = current_user
    Thread.current[:has_contabilidad]   = request.headers["has-contabilidad"] ? request.headers["has-contabilidad"].to_boolean : nil
    begin
      yield
    ensure
      Thread.current[:current_user]     = nil
      Thread.current[:has_contabilidad] = nil
    end
  end

  def testFunction

    res = Response.new
    # grupos = GrupoCuenta.all.includes(:cuentas_contables)
    # grupos_parsed = CatalogoCuenta::GrupoCuenta.iterator(grupos)
    # res.set_data(grupos_parsed)

    # user_id                  = get_current_user[:id]
    # result = Permiso.verificateUserPermiso(user_id, 'pre_venta')
    # result = Permiso.verificateUserPermiso(user_id, 'articulo')
    # result = Permiso.verificateUserPermiso(user_id, 'marca')

    # res = result
		TipoArticulo.all.each do | tipo_articulo |
			tipo_articulo.descripcion = "#{tipo_articulo.descripcion}"
			puts " "
			puts " "
			puts " "
			puts " "
			puts " ------ ".red * 8
			puts "ACTUALIZANDO #{tipo_articulo.descripcion.upcase}"
			puts " ------ ".red * 8
			puts " "
			puts " "
			puts " "
			resultado = TipoArticulo.create_update_tipo_articulo(tipo_articulo.attributes.with_indifferent_access, true)
			unless resultado.status_valid
				res = resultado
				break
			end
		end
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
