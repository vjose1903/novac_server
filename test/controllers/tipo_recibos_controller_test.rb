require 'test_helper'

class TipoRecibosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tipo_recibo = tipo_recibos(:one)
  end

  test "should get index" do
    get tipo_recibos_url, as: :json
    assert_response :success
  end

  test "should create tipo_recibo" do
    assert_difference('TipoRecibo.count') do
      post tipo_recibos_url, params: { tipo_recibo: {  } }, as: :json
    end

    assert_response 201
  end

  test "should show tipo_recibo" do
    get tipo_recibo_url(@tipo_recibo), as: :json
    assert_response :success
  end

  test "should update tipo_recibo" do
    patch tipo_recibo_url(@tipo_recibo), params: { tipo_recibo: {  } }, as: :json
    assert_response 200
  end

  test "should destroy tipo_recibo" do
    assert_difference('TipoRecibo.count', -1) do
      delete tipo_recibo_url(@tipo_recibo), as: :json
    end

    assert_response 204
  end
end
