class PermisosController < ApplicationController
	before_action :set_permiso, only: [:show]
	# GET /permiso
	def index
		opciones = get_parametros_opcionales
		return Response.new(params, HTTP_STATUS_CODE[:ok], Permiso.get_all, nil, opciones, Permiso.models_includes).send_response self
	end

	# GET /permiso/1
	def show
		return Response.new(params, nil, @permiso, nil).send_response self
	end

	def parsePermisosFront
		resultado = Permiso.parse_permisos_front()
		resultado.send_response self
	end

	def get_parametros_opcionales
    return {
      acciones:          validate_optional_param(params, 'acciones') ?          params['acciones'].to_boolean :          false,
      permisos_acciones: validate_optional_param(params, 'permisos_acciones') ? params['permisos_acciones'].to_boolean : false,
    }
  end

	private

	def set_permiso
		@permiso = Permiso.find(params[:id])
	end
end
