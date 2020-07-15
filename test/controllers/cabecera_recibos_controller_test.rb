require 'test_helper'

class CabeceraRecibosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cabecera_recibo = cabecera_recibos(:one)
  end

  test "should get index" do
    get cabecera_recibos_url, as: :json
    assert_response :success
  end

  test "should create cabecera_recibo" do
    assert_difference('CabeceraRecibo.count') do
      post cabecera_recibos_url, params: { cabecera_recibo: { cliente_id: @cabecera_recibo.cliente_id, devuelta: @cabecera_recibo.devuelta, forma_pago: @cabecera_recibo.forma_pago, numero_recibo: @cabecera_recibo.numero_recibo, total: @cabecera_recibo.total, user_id: @cabecera_recibo.user_id } }, as: :json
    end

    assert_response 201
  end

  test "should show cabecera_recibo" do
    get cabecera_recibo_url(@cabecera_recibo), as: :json
    assert_response :success
  end

  test "should update cabecera_recibo" do
    patch cabecera_recibo_url(@cabecera_recibo), params: { cabecera_recibo: { cliente_id: @cabecera_recibo.cliente_id, devuelta: @cabecera_recibo.devuelta, forma_pago: @cabecera_recibo.forma_pago, numero_recibo: @cabecera_recibo.numero_recibo, total: @cabecera_recibo.total, user_id: @cabecera_recibo.user_id } }, as: :json
    assert_response 200
  end

  test "should destroy cabecera_recibo" do
    assert_difference('CabeceraRecibo.count', -1) do
      delete cabecera_recibo_url(@cabecera_recibo), as: :json
    end

    assert_response 204
  end
end
