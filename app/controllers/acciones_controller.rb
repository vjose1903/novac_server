class AccionesController < ApplicationController
	before_action :set_accion, only: [:show]
	# GET /accion
	def index
		return Response.new(params, nil, Accion.all, nil).send_response self
	end

	# GET /accion/1
	def show
		return Response.new(params, nil, @accion, nil).send_response self
	end

	private

	def set_accion
		@accion = Accion.find(params[:id])
	end
end
