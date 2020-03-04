require 'test_helper'

class SecuenciaIngresosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @secuencia_ingreso = secuencia_ingresos(:one)
  end

  test "should get index" do
    get secuencia_ingresos_url, as: :json
    assert_response :success
  end

  test "should create secuencia_ingreso" do
    assert_difference('SecuenciaIngreso.count') do
      post secuencia_ingresos_url, params: { secuencia_ingreso: { secuencia: @secuencia_ingreso.secuencia, tipo_recibo_id: @secuencia_ingreso.tipo_recibo_id } }, as: :json
    end

    assert_response 201
  end

  test "should show secuencia_ingreso" do
    get secuencia_ingreso_url(@secuencia_ingreso), as: :json
    assert_response :success
  end

  test "should update secuencia_ingreso" do
    patch secuencia_ingreso_url(@secuencia_ingreso), params: { secuencia_ingreso: { secuencia: @secuencia_ingreso.secuencia, tipo_recibo_id: @secuencia_ingreso.tipo_recibo_id } }, as: :json
    assert_response 200
  end

  test "should destroy secuencia_ingreso" do
    assert_difference('SecuenciaIngreso.count', -1) do
      delete secuencia_ingreso_url(@secuencia_ingreso), as: :json
    end

    assert_response 204
  end
end
