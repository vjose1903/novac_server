require 'test_helper'

class CostosFletesHistorialesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @costo_flete_historial = costos_fletes_historiales(:one)
  end

  test "should get index" do
    get costos_fletes_historiales_url, as: :json
    assert_response :success
  end

  test "should create costo_flete_historial" do
    assert_difference('CostoFleteHistorial.count') do
      post costos_fletes_historiales_url, params: { costo_flete_historial: { costo: @costo_flete_historial.costo, costo_flete_id: @costo_flete_historial.costo_flete_id, estado: @costo_flete_historial.estado, municipio: @costo_flete_historial.municipio, user_id: @costo_flete_historial.user_id } }, as: :json
    end

    assert_response 201
  end

  test "should show costo_flete_historial" do
    get costo_flete_historial_url(@costo_flete_historial), as: :json
    assert_response :success
  end

  test "should update costo_flete_historial" do
    patch costo_flete_historial_url(@costo_flete_historial), params: { costo_flete_historial: { costo: @costo_flete_historial.costo, costo_flete_id: @costo_flete_historial.costo_flete_id, estado: @costo_flete_historial.estado, municipio: @costo_flete_historial.municipio, user_id: @costo_flete_historial.user_id } }, as: :json
    assert_response 200
  end

  test "should destroy costo_flete_historial" do
    assert_difference('CostoFleteHistorial.count', -1) do
      delete costo_flete_historial_url(@costo_flete_historial), as: :json
    end

    assert_response 204
  end
end
