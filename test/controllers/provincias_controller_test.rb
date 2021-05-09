require 'test_helper'

class ProvinciasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provincia = provincias(:one)
  end

  test "should get index" do
    get provincias_url, as: :json
    assert_response :success
  end

  test "should create provincia" do
    assert_difference('Provincia.count') do
      post provincias_url, params: { provincia: { nombre: @provincia.nombre } }, as: :json
    end

    assert_response 201
  end

  test "should show provincia" do
    get provincia_url(@provincia), as: :json
    assert_response :success
  end

  test "should update provincia" do
    patch provincia_url(@provincia), params: { provincia: { nombre: @provincia.nombre } }, as: :json
    assert_response 200
  end

  test "should destroy provincia" do
    assert_difference('Provincia.count', -1) do
      delete provincia_url(@provincia), as: :json
    end

    assert_response 204
  end
end
