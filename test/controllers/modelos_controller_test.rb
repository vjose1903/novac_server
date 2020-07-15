require 'test_helper'

class ModelosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @modelo = modelos(:one)
  end

  test "should get index" do
    get modelos_url, as: :json
    assert_response :success
  end

  test "should create modelo" do
    assert_difference('Modelo.count') do
      post modelos_url, params: { modelo: { descripcion: @modelo.descripcion, marca_id: @modelo.marca_id } }, as: :json
    end

    assert_response 201
  end

  test "should show modelo" do
    get modelo_url(@modelo), as: :json
    assert_response :success
  end

  test "should update modelo" do
    patch modelo_url(@modelo), params: { modelo: { descripcion: @modelo.descripcion, marca_id: @modelo.marca_id } }, as: :json
    assert_response 200
  end

  test "should destroy modelo" do
    assert_difference('Modelo.count', -1) do
      delete modelo_url(@modelo), as: :json
    end

    assert_response 204
  end
end
