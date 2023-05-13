class CuentasContablesController < ApplicationController
  before_action :set_cuenta_contable, only: [ :show, :deactivateOrReactivate ]


  # GET /cuentas_contables
  def index


    if has_filter_target(params)
      resultado      = CuentaContable.filtrar(params, get_parametros_opcionales)
      resultado.send_response self
    else

      cuentas        = CuentaContable.all.order('codigo ASC').where("#{get_parametros_opcionales[:"only_aux"] ? 'is_control=false' : ''} #{get_parametros_opcionales[:"only_control"] ? 'is_control=true' : ''}").includes(CuentaContable.models_includes)
      cuentas_send   = get_parametros_opcionales[:"iterator"] ? CatalogoCuenta::CuentaContable.iterator(cuentas, get_parametros_opcionales) : serialize_parser(cuentas, get_parametros_opcionales)

      return Response.new(params, nil, cuentas_send, nil).send_response self
    end
  end

  # GET /cuentas_contables/1
  def show
    return Response.new(params, nil, @cuenta_contable, nil, { all: true }).send_response self
  end

  def crear_actualizar_cuenta_contable
    res = CuentaContable.create_update_cuenta_contable(params, nil, true)
    res.send_response self
  end

  # POST /cuentas_contables
  def create
    crear_actualizar_cuenta_contable
  end

  # PATCH/PUT /cuentas_contables/1
  def update
    crear_actualizar_cuenta_contable
  end

  # PATCH /cuentas_contables/deactivate_or_reactivate/1
  def deactivateOrReactivate
    resultado = @cuenta_contable.deactivate_or_reactivate(params)
    resultado.send_response self
  end

  private

    def get_parametros_opcionales
      return {
        all:                 params[:all].present? ? params[:all]                               : true,
        cuenta_control:      params[:cuenta_control]                                           || false,
        cuenta_control_id:   params[:cuenta_control_id]                                        || false,
        iterator:            params[:iterator].present? ? params[:iterator].to_boolean          : false,
        only_aux:            params[:only_aux].present? ? params[:only_aux].to_boolean          : false,
        only_control:        params[:only_control].present? ? params[:only_control].to_boolean  : false,
        label:               params[:label].present? ? params[:label].to_boolean                : false,
      }
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_cuenta_contable
      respuesta = set_entidad(CuentaContable, params)
      @cuenta_contable = respuesta.get_data

      return respuesta.send_response self if @cuenta_contable.nil?
    end
end
