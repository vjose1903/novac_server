require 'test_helper'

class CostoFletesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @costo_flete = costo_fletes(:one)
  end

  test "should get index" do
    get costo_fletes_url, as: :json
    assert_response :success
  end

  test "should create costo_flete" do
    assert_difference('CostoFlete.count') do
      post costo_fletes_url, params: { costo_flete: { costo: @costo_flete.costo, municipio_id: @costo_flete.municipio_id } }, as: :json
    end

    assert_response 201
  end

  test "should show costo_flete" do
    get costo_flete_url(@costo_flete), as: :json
    assert_response :success
  end

  test "should update costo_flete" do
    patch costo_flete_url(@costo_flete), params: { costo_flete: { costo: @costo_flete.costo, municipio_id: @costo_flete.municipio_id } }, as: :json
    assert_response 200
  end

  test "should destroy costo_flete" do
    assert_difference('CostoFlete.count', -1) do
      delete costo_flete_url(@costo_flete), as: :json
    end

    assert_response 204
  end
end
