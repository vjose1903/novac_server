class ProvinciasController < ApplicationController
  before_action :set_provincia, only: [:show, :update, :destroy]

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
    optional_params = {
      all:        validate_optional_param(params, 'all')    ? params['all'].to_boolean    : true,
      id:         validate_optional_param(params, 'id')     ? params['id'].to_boolean     : false,
      nombre:     validate_optional_param(params, 'nombre') ? params['nombre'].to_boolean : false,
      codigo:     validate_optional_param(params, 'codigo') ? params['codigo'].to_boolean : false,

    }

    municipios = %w[municipios.id municipios.nombre municipios.codigo municipios.provincia.id municipios.provincia.nombre ]
    optional_params[:municipios] = {
      all: false,
      id:              validate_optional_param(params, 'municipios.id')           ? params['municipios.id'].to_boolean                : false,
      nombre:          validate_optional_param(params, 'municipios.nombre')       ? params['municipios.nombre'].to_boolean            : false,
      codigo:          validate_optional_param(params, 'municipios.codigo')       ? params['municipios.codigo'].to_boolean            : false,
      provincia: {
        all: false,
        id:       validate_optional_param(params, 'municipios.provincia.id')      ? params['municipios.provincia.id'].to_boolean      : false,
        nombre:   validate_optional_param(params, 'municipios.provincia.nombre')  ? params['municipios.provincia.nombre'].to_boolean  : false,
      }
    } if municipios.any? { |param| validate_optional_param(params, param) }

    return optional_params
  end

  private
    # Use callbacks to share common setup or constraints between actions.

    def set_provincia
      @provincia = Provincia.find(params[:id])
    end

end
