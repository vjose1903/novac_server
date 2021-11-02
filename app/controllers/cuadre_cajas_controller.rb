class CuadreCajasController < ApplicationController
  before_action :set_cuadre, only: [:show, :destroy]

  # GET /cuadre_cajas
  def index    
    return Response.new(nil, CuadreCaja.all.where({ estado: true}).order('id DESC'), nil, {}).send_response self
  end

  # GET /cuadre_cajas/1
  def show
    return Response.new(nil, @cuadre_caja, nil, {}).send_response self
  end

  
  # POST /cuadre_cajas
  def create
    resultado = CuadreCaja.makecuadre(current_user, params)
    resultado.send_response self
  end

  def check_today_cuadre
    today_cuadre = CuadreCaja.where({ fecha_equivalente: DateTime.now.beginning_of_day..DateTime.now.end_of_day}).empty?
    puts "bool: ".red + "#{{ :existe_cuadre_hoy => !today_cuadre }}"
    return Response.new(nil, { :existe_cuadre_hoy => !today_cuadre }, nil, {}).send_response self
  end

  # DELETE /cuadre_cajas/1
  def destroy
    resultado = borrar_entidad(@cuadre_caja)
    resultado.send_response self
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_cuadre
    respuesta = set_entidad(CuadreCaja, params)
    @cuadre_caja = respuesta.get_data
      
    return respuesta.send_response self if @cuadre_caja.nil?
  end

  # Only allow a trusted parameter "white list" through.
  def cuadre_params
    params.require(:cuadre_caja).permit(:user_id, :total_general, :total_venta_credito, :total_venta_contado, :total_recibo_ingreso, :total_anterior)
  end
end
