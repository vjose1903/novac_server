require "test_helper"

class OtrosCostosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @otro_costo = otros_costos(:one)
  end

  test "should get index" do
    get otros_costos_url, as: :json
    assert_response :success
  end

  test "should create otro_costo" do
    assert_difference('OtroCosto.count') do
      post otros_costos_url, params: { otro_costo: { costo: @otro_costo.costo, descripcion: @otro_costo.descripcion } }, as: :json
    end

    assert_response 201
  end

  test "should show otro_costo" do
    get otro_costo_url(@otro_costo), as: :json
    assert_response :success
  end

  test "should update otro_costo" do
    patch otro_costo_url(@otro_costo), params: { otro_costo: { costo: @otro_costo.costo, descripcion: @otro_costo.descripcion } }, as: :json
    assert_response 200
  end

  test "should destroy otro_costo" do
    assert_difference('OtroCosto.count', -1) do
      delete otro_costo_url(@otro_costo), as: :json
    end

    assert_response 204
  end
end
