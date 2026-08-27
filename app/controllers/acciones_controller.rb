class AccionesController < ApplicationController
	before_action :set_permiso, only: [:show]
	# GET /accion
	def index
		return Response.new(params, HTTP_STATUS_CODE[:ok], Accion.order('acciones.id ASC'), nil, {all: true}).send_response self
	end

	# GET /accion/1
	def show
		return Response.new(params, nil, @accion, nil).send_response self
	end

	private

	def set_permiso
		@accion = Accion.find(params[:id])
	end
end
