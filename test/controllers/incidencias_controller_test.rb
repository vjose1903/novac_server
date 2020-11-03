require 'test_helper'

class IncidenciasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @incidencia = incidencias(:one)
  end

  test "should get index" do
    get incidencias_url, as: :json
    assert_response :success
  end

  test "should create incidencia" do
    assert_difference('Incidencia.count') do
      post incidencias_url, params: { incidencia: { descripcion: @incidencia.descripcion, referencia: @incidencia.referencia } }, as: :json
    end

    assert_response 201
  end

  test "should show incidencia" do
    get incidencia_url(@incidencia), as: :json
    assert_response :success
  end

  test "should update incidencia" do
    patch incidencia_url(@incidencia), params: { incidencia: { descripcion: @incidencia.descripcion, referencia: @incidencia.referencia } }, as: :json
    assert_response 200
  end

  test "should destroy incidencia" do
    assert_difference('Incidencia.count', -1) do
      delete incidencia_url(@incidencia), as: :json
    end

    assert_response 204
  end
end
