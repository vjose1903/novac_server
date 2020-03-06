require 'test_helper'

class SecuenciaComprobantesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @secuencia_comprobante = secuencia_comprobantes(:one)
  end

  test "should get index" do
    get secuencia_comprobantes_url, as: :json
    assert_response :success
  end

  test "should create secuencia_comprobante" do
    assert_difference('SecuenciaComprobante.count') do
      post secuencia_comprobantes_url, params: { secuencia_comprobante: {  } }, as: :json
    end

    assert_response 201
  end

  test "should show secuencia_comprobante" do
    get secuencia_comprobante_url(@secuencia_comprobante), as: :json
    assert_response :success
  end

  test "should update secuencia_comprobante" do
    patch secuencia_comprobante_url(@secuencia_comprobante), params: { secuencia_comprobante: {  } }, as: :json
    assert_response 200
  end

  test "should destroy secuencia_comprobante" do
    assert_difference('SecuenciaComprobante.count', -1) do
      delete secuencia_comprobante_url(@secuencia_comprobante), as: :json
    end

    assert_response 204
  end
end
