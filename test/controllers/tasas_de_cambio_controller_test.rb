require "test_helper"

class TasasDeCambioControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tasa_cambio = tasas_de_cambio(:one)
  end

  test "should get index" do
    get tasas_de_cambio_url, as: :json
    assert_response :success
  end

  test "should create tasa_cambio" do
    assert_difference("TasaCambio.count") do
      post tasas_de_cambio_url, params: { tasa_cambio: { divisa_id: @tasa_cambio.divisa_id, fecha_equivalente: @tasa_cambio.fecha_equivalente, valor: @tasa_cambio.valor } }, as: :json
    end

    assert_response :created
  end

  test "should show tasa_cambio" do
    get tasa_cambio_url(@tasa_cambio), as: :json
    assert_response :success
  end

  test "should update tasa_cambio" do
    patch tasa_cambio_url(@tasa_cambio), params: { tasa_cambio: { divisa_id: @tasa_cambio.divisa_id, fecha_equivalente: @tasa_cambio.fecha_equivalente, valor: @tasa_cambio.valor } }, as: :json
    assert_response :success
  end

  test "should destroy tasa_cambio" do
    assert_difference("TasaCambio.count", -1) do
      delete tasa_cambio_url(@tasa_cambio), as: :json
    end

    assert_response :no_content
  end
end
