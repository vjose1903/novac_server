class ProvinciasController < ApplicationController
  before_action :set_provincia, only: [:show, :destroy]

  # GET /provincias
  def index
    return Response.new(params, nil, Provincia.all, nil, get_parametros_opcionales).send_response self
  end

  # GET /provincias/1
  def show
    return Response.new(params, nil, @provincia, nil, get_parametros_opcionales).send_response self
  end

  def crear_actualizar_provincia
    parametros = params
    parametros["id"] = params["id"] if params["id"]

    resultado = Provincia.crear_actualizar_provincia(parametros, true)
    resultado.send_response self
  end

  # POST /provincias
  def create
    crear_actualizar_provincia
  end

  # PATCH/PUT /provincias/1
  def update
    crear_actualizar_provincia
  end

  # DELETE /provincias/1
  def destroy
    @provincia.destroy
  end

  def get_parametros_opcionales
    return {
      municipios: params['municipios'] || false,
    }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_provincia
      @provincia = Provincia.find(params[:id])
    end

end
