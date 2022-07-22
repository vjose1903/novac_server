class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  # protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  # if ENV["RAILS_ENV"] != "development"
    before_action :validateUserIsLogging!
  # end

  around_action :encarsular_usuario

	def validateUserIsLogging!
		unless user_signed_in?
			render json: { msg: "Para realizar esta accion debe de iniciar sesión.", action: "close_ssesion" }, status: HTTP_STATUS_CODE[:unauthorized] unless params["controller"] == "devise_token_auth/sessions"
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

		CabeceraFactura.all.each do |factura|
			identificador         = CabeceraFactura.makeIdentificador(factura)
			my_print_log("identificador ".red + "#{identificador}" )
			factura.identificador = identificador

			factura.save!
		end

		res.set_data("fin")
    res.send_response self

	end

  def testFunction_
    res = Response.new

    res.send_response self

    #  -------------------------------------------------------------------------------------

    # a = CabeceraFactura.find_by_id(3244)
    # puts ":::::::: a".red + "#{a.to_json}"

    # b = serialize_parser(a,{all:true})
    # render json:  b.to_json, status: 200


    # param = params[:param]
    # res = User.mudar_info(param)
    # render json: { body: res }, status: 200
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
