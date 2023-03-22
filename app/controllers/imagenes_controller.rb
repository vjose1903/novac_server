class ImagenesController < ApplicationController
  before_action :set_imagen, only: [:show, :destroy]

  # GET /imagenes
  def index
    return Response.new(params, nil, Imagen.all.order('id ASC'), nil, {all: true}).send_response self
    render json: @imagenes
  end

  # GET /imagenes/1
  def show
		return Response.new(params, nil, @imagen, nil, {all: true}).send_response self
  end

  # DELETE /imagenes/1
  def destroy
    resultado = borrar_entidad(@imagen)
    resultado.send_response self
  end

  private
  def set_imagen
		respuesta = set_entidad(Imagen, params)
    @imagen   = respuesta.get_data

    return respuesta.send_response self if @imagen.nil?
  end
end
