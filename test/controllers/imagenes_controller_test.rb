require 'test_helper'

class ImagenesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @imagen = imagenes(:one)
  end

  test "should get index" do
    get imagenes_url, as: :json
    assert_response :success
  end

  test "should create imagen" do
    assert_difference('Imagen.count') do
      post imagenes_url, params: { imagen: { base_64: @imagen.base_64, fileName: @imagen.fileName } }, as: :json
    end

    assert_response 201
  end

  test "should show imagen" do
    get imagen_url(@imagen), as: :json
    assert_response :success
  end

  test "should update imagen" do
    patch imagen_url(@imagen), params: { imagen: { base_64: @imagen.base_64, fileName: @imagen.fileName } }, as: :json
    assert_response 200
  end

  test "should destroy imagen" do
    assert_difference('Imagen.count', -1) do
      delete imagen_url(@imagen), as: :json
    end

    assert_response 204
  end
end
