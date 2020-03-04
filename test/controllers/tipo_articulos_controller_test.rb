require 'test_helper'

class TipoArticulosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tipo_articulo = tipo_articulos(:one)
  end

  test "should get index" do
    get tipo_articulos_url, as: :json
    assert_response :success
  end

  test "should create tipo_articulo" do
    assert_difference('TipoArticulo.count') do
      post tipo_articulos_url, params: { tipo_articulo: { descripcion: @tipo_articulo.descripcion } }, as: :json
    end

    assert_response 201
  end

  test "should show tipo_articulo" do
    get tipo_articulo_url(@tipo_articulo), as: :json
    assert_response :success
  end

  test "should update tipo_articulo" do
    patch tipo_articulo_url(@tipo_articulo), params: { tipo_articulo: { descripcion: @tipo_articulo.descripcion } }, as: :json
    assert_response 200
  end

  test "should destroy tipo_articulo" do
    assert_difference('TipoArticulo.count', -1) do
      delete tipo_articulo_url(@tipo_articulo), as: :json
    end

    assert_response 204
  end
end
