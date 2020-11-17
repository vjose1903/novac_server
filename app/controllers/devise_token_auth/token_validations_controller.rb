# frozen_string_literal: true

module DeviseTokenAuth
  class TokenValidationsController < DeviseTokenAuth::ApplicationController
    skip_before_action :assert_is_devise_resource!, only: [:validate_token]
    before_action :set_user_by_token, only: [:validate_token]

    def validate_token
      # @resource will have been set by set_user_by_token concern
      if @resource
        if @resource[:estado] == "I"
          user = remove_instance_variable(:@resource) if @resource
          client_id = remove_instance_variable(:@client_id) if @client_id
          remove_instance_variable(:@token) if @token

          if user && client_id && user.tokens[client_id]
            user.tokens.delete(client_id)
            user.save!

            yield user if block_given?

            # render_destroy_success
            return render json: { msg: "Usuario desactivado, favor de comunicarse con el administrador del sistema." }, status: 401
          end
        else
          yield @resource if block_given?
          render_validate_token_success
        end
      else
        render_validate_token_error
      end
    end

    protected

    def render_validate_token_success
      datos = {
        success: true,
        data: resource_data(resource_json: @resource.token_validation_response),
      }
      # datos[:data][:configuration] = Configuracion.all.limit(1)[0]
      # datos[:data][:permisos] = User.getPermisos(datos[:data]['id'])
      render json: datos
    end

    def render_validate_token_error
      render_error(401, I18n.t('devise_token_auth.token_validations.invalid'))
      # render json: { msg: "Token invalido!" }, status: 200
    end
  end
end
