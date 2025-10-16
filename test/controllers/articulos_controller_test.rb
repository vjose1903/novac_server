require 'test_helper'

class ArticulosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @articulo = articulos(:one)
  end

  test "should get index" do
    get articulos_url, as: :json
    assert_response :success
  end

  test "should create articulo" do
    assert_difference('Articulo.count') do
      post articulos_url, params: { articulo: { codigo: @articulo.codigo, costo: @articulo.costo, existencia: @articulo.existencia, fecha_ingreso: @articulo.fecha_ingreso, is_detallable: @articulo.is_detallable, medida: @articulo.medida, nombre: @articulo.nombre, precio: @articulo.precio, secuencia: @articulo.secuencia, tipo_articulo_id: @articulo.tipo_articulo_id } }, as: :json
    end

    assert_response 201
  end

  test "should show articulo" do
    get articulo_url(@articulo), as: :json
    assert_response :success
  end

  test "should update articulo" do
    patch articulo_url(@articulo), params: { articulo: { codigo: @articulo.codigo, costo: @articulo.costo, existencia: @articulo.existencia, fecha_ingreso: @articulo.fecha_ingreso, is_detallable: @articulo.is_detallable, medida: @articulo.medida, nombre: @articulo.nombre, precio: @articulo.precio, secuencia: @articulo.secuencia, tipo_articulo_id: @articulo.tipo_articulo_id } }, as: :json
    assert_response 200
  end

  test "should destroy articulo" do
    assert_difference('Articulo.count', -1) do
      delete articulo_url(@articulo), as: :json
    end

    assert_response 204
  end
end
