class TipoArticulosController < ApplicationController

  # GET /tipo_articulos
  def index
		return Response.new(params, nil, TipoArticulo.all, nil, {all: true}).send_response self
  end

end
