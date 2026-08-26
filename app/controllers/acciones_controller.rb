class AccionesController < ApplicationController
	before_action :set_permiso, only: [:show]
	# GET /accion
	def index
		resultado = {data: Accion.order('acciones.id ASC').as_json, msg: []}
		render body: resultado.to_json, status: HTTP_STATUS_CODE[:ok], content_type: 'application/json'
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
