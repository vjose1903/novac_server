require 'test_helper'

class CuadreCajasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cuadre_caja = cuadre_cajas(:one)
  end

  test "should get index" do
    get cuadre_cajas_url, as: :json
    assert_response :success
  end

  test "should create cuadre_caja" do
    assert_difference('CuadreCaja.count') do
      post cuadre_cajas_url, params: { cuadre_caja: { total_anterior: @cuadre_caja.total_anterior, total_general: @cuadre_caja.total_general, total_recibo_ingreso: @cuadre_caja.total_recibo_ingreso, total_venta_contado: @cuadre_caja.total_venta_contado, total_venta_credito: @cuadre_caja.total_venta_credito, user_id: @cuadre_caja.user_id } }, as: :json
    end

    assert_response 201
  end

  test "should show cuadre_caja" do
    get cuadre_caja_url(@cuadre_caja), as: :json
    assert_response :success
  end

  test "should update cuadre_caja" do
    patch cuadre_caja_url(@cuadre_caja), params: { cuadre_caja: { total_anterior: @cuadre_caja.total_anterior, total_general: @cuadre_caja.total_general, total_recibo_ingreso: @cuadre_caja.total_recibo_ingreso, total_venta_contado: @cuadre_caja.total_venta_contado, total_venta_credito: @cuadre_caja.total_venta_credito, user_id: @cuadre_caja.user_id } }, as: :json
    assert_response 200
  end

  test "should destroy cuadre_caja" do
    assert_difference('CuadreCaja.count', -1) do
      delete cuadre_caja_url(@cuadre_caja), as: :json
    end

    assert_response 204
  end
end
