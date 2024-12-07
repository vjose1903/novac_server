# frozen_string_literal: true

# see http://www.emilsoman.com/blog/2013/05/18/building-a-tested/
module DeviseTokenAuth
  class SessionsController < DeviseTokenAuth::ApplicationController
    include ActionController::RequestForgeryProtection

    protect_from_forgery with: :null_session, if: -> { Rails.env.development? && postman_request? }
    skip_before_action :verify_authenticity_token, if: -> { Rails.env.development? && postman_request? }

    before_action :set_user_by_token, only: [:destroy]
    after_action :reset_session, only: [:destroy]

    def new
      render_new_error
    end

    def create
      begin
        @res = Response.new

        # Reset de sesión al inicio
        reset_session

        @user_en_turno = User.find_by_usuario(params[:usuario])

        return render_create_error_bad_credentials if @user_en_turno.nil?

        @resource = @user_en_turno

        # Validar estado antes de continuar
        if @resource[:estado] == "I"
          @res.set_status(HTTP_STATUS_CODE[:locked])
          @res.add_msg("Usuario desactivado, favor de comunicarse con el administrador del sistema.")
          return @res.send_response self
        end

        field = (params.keys.map(&:to_sym) & resource_class.authentication_keys).first

        if field
          q_value = get_case_insensitive_field_from_resource_params(field)
        end

        if @resource && valid_params?(field, q_value) && (!@resource.respond_to?(:active_for_authentication?) || @resource.active_for_authentication?)
          valid_password = @resource.valid_password?(resource_params[:password])

          if valid_password
            @token = @resource.create_token
            @resource.save

            sign_in(:user, @resource, store: false, bypass: false)

            render_create_success
          else
            return render_create_error_bad_credentials
          end
        else
          render_create_error_bad_credentials
        end

      rescue => e
        @res.set_status(HTTP_STATUS_CODE[:unauthorized])
        @res.add_msg("Error en la autenticación: #{e.message}")
        @res.send_response self
      end
    end

    def destroy
      # remove auth instance variables so that after_action does not run
      user = remove_instance_variable(:@resource) if @resource
      client_id = remove_instance_variable(:@client_id) if @client_id
      remove_instance_variable(:@token) if @token

      if user && client_id && user.tokens[client_id]
        user.tokens.delete(client_id)
        user.save!

        yield user if block_given?

        render_destroy_success
      else
        render_destroy_error
      end
    end

    protected

    def valid_params?(key, val)
      resource_params[:password] && key && val
    end

    def get_auth_params
      auth_key = nil
      auth_val = nil

      # iterate thru allowed auth keys, use first found
      resource_class.authentication_keys.each do |k|
        if resource_params[k]
          auth_val = resource_params[k]
          auth_key = k
          break
        end
      end

      # honor devise configuration for case_insensitive_keys
      if resource_class.case_insensitive_keys.include?(auth_key)

        # auth_val.downcase!
      end

      { key: auth_key, val: auth_val }
    end

    def render_new_error
      render_error(405, I18n.t("devise_token_auth.sessions.not_supported"))
    end

    def render_create_success
      data = resource_data(resource_json: @resource.token_validation_response)
      user = User.find_by_id(data["id"])

      @res.set_data(@user_en_turno, {documentos_de_identidad:true, all:true, permisos: true, roles: true, cuentas_contables:false})

      @res.send_response self
    end

    def render_create_error_not_confirmed
      render_error(401, I18n.t("devise_token_auth.sessions.not_confirmed", email: @resource.email))
    end

    def render_create_error_bad_credentials
      @res.set_status(HTTP_STATUS_CODE[:unauthorized])
      @res.add_msg("Los datos proporcionados no son correctos.")
      @res.send_response self
    end

    def render_destroy_success
      render json: {
        success: true,
      }, status: 200
    end

    def render_destroy_error
      render_error(404, I18n.t("devise_token_auth.sessions.user_not_found"))
    end

    private

    def resource_params
      params.permit(*params_for_resource(:sign_in))
    end

    def postman_request?
      request.headers['HTTP_USER_AGENT']&.include?('PostmanRuntime')
    end
  end
end
