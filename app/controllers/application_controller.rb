class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  # protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  # if ENV["RAILS_ENV"] != "development"
    before_action :validateUserIsLogging!, unless: :devise_controller?
  # end

  around_action :encarsular_usuario

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
			factura.identificador = CabeceraFactura.makeIdentificador(factura)
			factura.save!
		end

		res.set_data("fin")
    res.send_response self

	end

  def testFunction_

    # prueba = RecibosIngreso.puedeAnular(params)
    # prueba.send_response self

    # =================================================================
    # PONER LOS ARTICULOS QUE TENGAN FORMULAS COMO COMBO
    # =================================================================
    res = Response.new
    # #  -------------------------------------------------------------------------------------
    # formulas = FormulasProductosTerminado.all

    # formulas.each do |formula|
    #   puts "formula.articulo".red + "#{formula.articulo.contenido_articulos.to_json} "
    # end

    # select * from mantenimiento_formulas order by created_at desc

    obj = {}
    formulas_sin_repetir = []

    mantenimiento = MantenimientoFormula.select("mantenimiento_formulas.*, articulos.nombre").joins("inner join articulos on mantenimiento_formulas.articulo_id = articulos.id").order("mantenimiento_formulas.created_at desc")
    acu = 0
    mantenimiento.each do |artic|

      unless formulas_sin_repetir.any? { |item| item.articulo_id == artic.articulo_id && item.secuencia != artic.secuencia }

        obj["#{artic.articulo_id}"] = [] if obj["#{artic.articulo_id}"].blank?

        obj["#{artic.articulo_id}"].push(artic)

        formulas_sin_repetir.push(artic)

      end
    end

    obj.each { |key, value|
      puts "key:".red + " #{key}"
      puts "value:".green + " #{value}"

      formula_b = FormulasProductosTerminado.where({articulo_id: key}).count()
      puts "formula_b:".yellow + " #{formula_b}"
      "-------" * 10


      if formula_b == 0
        value.each do |f|
          nueva_formula = FormulasProductosTerminado.new()
          nueva_formula.articulo_id        = f.articulo_id
          nueva_formula.cantidad           = f.cantidad
          nueva_formula.costo              = f.costo
          nueva_formula.articulo_combo     = f.articulo_combo
          nueva_formula.precio             = f.precio
          nueva_formula.medida             = "Libra"

          nueva_formula.save!
        end

      end

      acu +=1
      puts " "
     }


    puts "cuenta ".yellow + "#{acu}"
    res.set_data('fin')
    res.send_response self

    # articulos = Articulo.joins("inner join formulas_productos_terminados on formulas_productos_terminados.articulo_id = articulos.id").group("articulos.id")

    # articulos.each do |artic|
    #   artic.is_combo = true
    #   unless artic.save!
    #     res.add_msg("ERROR")
    #     res.add_msgs(artic.errors.to_a)
    #     return res
    #   end
    # end

    # res.set_data(articulos)
    # res.send_response self

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


  def validateUserIsLogging!
      render json: { msg: "Para realizar esta accion debe de iniciar sesión." }, status: HTTP_STATUS_CODE[:unauthorized] unless user_signed_in?
  end

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
