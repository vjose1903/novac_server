class CuadreCajasController < ApplicationController
  before_action :set_cuadre, only: [:show, :update, :destroy, :submit, :review, :approve, :reject, :reopen]

  # GET /cuadre_cajas
  def index
    resultado = CuadreCaja.listado(params)
    resultado.send_response self
  end

  # GET /cuadre_cajas/1
  def show
    return Response.new(params, nil, @cuadre_caja, nil, {all: true}).send_response self
  end


  # POST /cuadre_cajas
  def create
    resultado = CuadreCaja.makecuadre(params)
    resultado.send_response self
  end

  def update
    resultado = CuadreCaja.update_detailed_closing(@cuadre_caja, params)
    resultado.send_response self
  end

  def systemIncomePreview
    resultado = CuadreCaja.prepare_closing(params)
    resultado.send_response self
  end

  def prepare
    resultado = CuadreCaja.prepare_closing(params)
    resultado.send_response self
  end

  def submit
    transition('submitted')
  end

  def review
    transition('reviewed')
  end

  def approve
    transition('approved')
  end

  def reject
    transition('rejected')
  end

  def reopen
    transition('reopened')
  end

  def checkTodayCuadre
    today_cuadre = CuadreCaja.where({ fecha_equivalente: DateTime.now.beginning_of_day..DateTime.now.end_of_day}).empty?
    return Response.new(params, nil, { existe_cuadre_hoy: !today_cuadre } , nil, {all: true}).send_response self
  end

  # DELETE /cuadre_cajas/1
  def destroy
    if @cuadre_caja.approved?
      resultado = Response.new
      resultado.set_status(HTTP_STATUS_CODE[:conflict])
      resultado.add_msg('No se puede eliminar un cuadre aprobado')
      return resultado.send_response self
    end

    resultado = borrar_entidad(@cuadre_caja)
    resultado.send_response self
  end

  private

  def transition(status)
    resultado = @cuadre_caja.transition_to!(status, get_current_user, params[:reason] || params[:motivo])
    resultado.send_response self
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_cuadre
    respuesta = set_entidad(CuadreCaja, params)
    @cuadre_caja = respuesta.get_data

    return respuesta.send_response self if @cuadre_caja.nil?
  end

end
