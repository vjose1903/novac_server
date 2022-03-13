class PermisosController < ApplicationController
	before_action :set_permiso, only: [:show]
	# GET /permiso
	def index
		return Response.new(params, nil, Permiso.all, nil, get_parametros_opcionales).send_response self
	end

	# GET /permiso/1
	def show
		return Response.new(params, nil, @permiso, nil).send_response self
	end

	def get_parametros_opcionales
    return {
      acciones: params['acciones'] || false,
      permisos_acciones: params['permisos_acciones'] || false,
    }
  end

	private

	def set_permiso
		@permiso = Permiso.find(params[:id])
	end
end
