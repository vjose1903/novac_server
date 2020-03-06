require 'test_helper'

class SecuenciaFacturasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @secuencia_factura = secuencia_facturas(:one)
  end

  test "should get index" do
    get secuencia_facturas_url, as: :json
    assert_response :success
  end

  test "should create secuencia_factura" do
    assert_difference('SecuenciaFactura.count') do
      post secuencia_facturas_url, params: { secuencia_factura: {  } }, as: :json
    end

    assert_response 201
  end

  test "should show secuencia_factura" do
    get secuencia_factura_url(@secuencia_factura), as: :json
    assert_response :success
  end

  test "should update secuencia_factura" do
    patch secuencia_factura_url(@secuencia_factura), params: { secuencia_factura: {  } }, as: :json
    assert_response 200
  end

  test "should destroy secuencia_factura" do
    assert_difference('SecuenciaFactura.count', -1) do
      delete secuencia_factura_url(@secuencia_factura), as: :json
    end

    assert_response 204
  end
end
