require 'test_helper'

class DetalleRecibosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @detalle_recibo = detalle_recibos(:one)
  end

  test "should get index" do
    get detalle_recibos_url, as: :json
    assert_response :success
  end

  test "should create detalle_recibo" do
    assert_difference('DetalleRecibo.count') do
      post detalle_recibos_url, params: { detalle_recibo: {  } }, as: :json
    end

    assert_response 201
  end

  test "should show detalle_recibo" do
    get detalle_recibo_url(@detalle_recibo), as: :json
    assert_response :success
  end

  test "should update detalle_recibo" do
    patch detalle_recibo_url(@detalle_recibo), params: { detalle_recibo: {  } }, as: :json
    assert_response 200
  end

  test "should destroy detalle_recibo" do
    assert_difference('DetalleRecibo.count', -1) do
      delete detalle_recibo_url(@detalle_recibo), as: :json
    end

    assert_response 204
  end
end
