require 'test_helper'

class RecibosIngresosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @recibos_ingreso = recibos_ingresos(:one)
  end

  test "should get index" do
    get recibos_ingresos_url, as: :json
    assert_response :success
  end

  test "should create recibos_ingreso" do
    assert_difference('RecibosIngreso.count') do
      post recibos_ingresos_url, params: { recibos_ingreso: {  } }, as: :json
    end

    assert_response 201
  end

  test "should show recibos_ingreso" do
    get recibos_ingreso_url(@recibos_ingreso), as: :json
    assert_response :success
  end

  test "should update recibos_ingreso" do
    patch recibos_ingreso_url(@recibos_ingreso), params: { recibos_ingreso: {  } }, as: :json
    assert_response 200
  end

  test "should destroy recibos_ingreso" do
    assert_difference('RecibosIngreso.count', -1) do
      delete recibos_ingreso_url(@recibos_ingreso), as: :json
    end

    assert_response 204
  end
end
