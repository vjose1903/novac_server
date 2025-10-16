require 'test_helper'

class SuplidoresControllerTest < ActionDispatch::IntegrationTest
  setup do
    @suplidor = suplidores(:one)
  end

  test "should get index" do
    get suplidores_url, as: :json
    assert_response :success
  end

  test "should create suplidor" do
    assert_difference('Suplidor.count') do
      post suplidores_url, params: { suplidor: { direccion: @suplidor.direccion, email: @suplidor.email, nombre: @suplidor.nombre, telefono: @suplidor.telefono } }, as: :json
    end

    assert_response 201
  end

  test "should show suplidor" do
    get suplidor_url(@suplidor), as: :json
    assert_response :success
  end

  test "should update suplidor" do
    patch suplidor_url(@suplidor), params: { suplidor: { direccion: @suplidor.direccion, email: @suplidor.email, nombre: @suplidor.nombre, telefono: @suplidor.telefono } }, as: :json
    assert_response 200
  end

  test "should destroy suplidor" do
    assert_difference('Suplidor.count', -1) do
      delete suplidor_url(@suplidor), as: :json
    end

    assert_response 204
  end
end
