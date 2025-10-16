require 'test_helper'

class ContenidoArticulosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @contenido_articulo = contenido_articulos(:one)
  end

  test "should get index" do
    get contenido_articulos_url, as: :json
    assert_response :success
  end

  test "should create contenido_articulo" do
    assert_difference('ContenidoArticulo.count') do
      post contenido_articulos_url, params: { contenido_articulo: { articulo_id: @contenido_articulo.articulo_id, cantidad: @contenido_articulo.cantidad, costo: @contenido_articulo.costo, medida: @contenido_articulo.medida, precio: @contenido_articulo.precio, referencia: @contenido_articulo.referencia } }, as: :json
    end

    assert_response 201
  end

  test "should show contenido_articulo" do
    get contenido_articulo_url(@contenido_articulo), as: :json
    assert_response :success
  end

  test "should update contenido_articulo" do
    patch contenido_articulo_url(@contenido_articulo), params: { contenido_articulo: { articulo_id: @contenido_articulo.articulo_id, cantidad: @contenido_articulo.cantidad, costo: @contenido_articulo.costo, medida: @contenido_articulo.medida, precio: @contenido_articulo.precio, referencia: @contenido_articulo.referencia } }, as: :json
    assert_response 200
  end

  test "should destroy contenido_articulo" do
    assert_difference('ContenidoArticulo.count', -1) do
      delete contenido_articulo_url(@contenido_articulo), as: :json
    end

    assert_response 204
  end
end
