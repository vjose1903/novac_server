class EcfReceptionsController < ApplicationController
  before_action :set_ecf_reception, only: %i[ show update destroy ]

  # GET /ecf_receptions
  def index
		return Response.new(params, nil, EcfReception.all, nil, get_parametros_opcionales).send_response self
	end

  # GET /ecf_receptions/1
  def show
    return Response.new(params, nil, @ecf_reception, nil, get_parametros_opcionales).send_response self
  end

  # approveDenyEcf

  def get_parametros_opcionales
		optional_params = {
			all:             validate_optional_param(params, 'all')            ? params['all'].to_boolean             : true,
      eNCF:            validate_optional_param(params, 'eNCF')           ? params['eNCF'].to_boolean            : false,
      rnc_emisor:      validate_optional_param(params, 'rnc_emisor')     ? params['rnc_emisor'].to_boolean      : false,
      rnc_comprador:   validate_optional_param(params, 'rnc_comprador')  ? params['rnc_comprador'].to_boolean   : false,
      monto_total:     validate_optional_param(params, 'monto_total')    ? params['monto_total'].to_boolean     : false,
      suplidor_id:     validate_optional_param(params, 'suplidor_id')    ? params['suplidor_id'].to_boolean     : false,
			suplidor: {
				all: false,
				id:              validate_optional_param(params, 'suplidor.id')              ? params['suplidor.id'].to_boolean              : false,
				nombre:          validate_optional_param(params, 'suplidor.nombre')          ? params['suplidor.nombre'].to_boolean          : false,
				telefono:        validate_optional_param(params, 'suplidor.telefono')        ? params['suplidor.telefono'].to_boolean        : false,
				direccion:       validate_optional_param(params, 'suplidor.direccion')       ? params['suplidor.direccion'].to_boolean       : false,
        nombre_completo: validate_optional_param(params, 'suplidor.nombre_completo') ? params['suplidor.nombre_completo'].to_boolean : false,
        documentos_de_identidad: {
          all: false,
          id:          validate_optional_param(params, 'suplidor.documentos_de_identidad.id')          ? params['suplidor.documentos_de_identidad.id'].to_boolean          : false,
          documento:   validate_optional_param(params, 'suplidor.documentos_de_identidad.documento')   ? params['suplidor.documentos_de_identidad.documento'].to_boolean   : false,
          descripcion: validate_optional_param(params, 'suplidor.documentos_de_identidad.descripcion') ? params['suplidor.documentos_de_identidad.descripcion'].to_boolean : false,
          principal:   validate_optional_param(params, 'suplidor.documentos_de_identidad.principal')   ? params['suplidor.documentos_de_identidad.principal'].to_boolean   : false,
        }
			}
		}
	end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ecf_reception
      respuesta = set_entidad(EcfReception, params)
			@ecf_reception = respuesta.get_data

			return respuesta.send_response self if @ecf_reception.nil?
    end
end
