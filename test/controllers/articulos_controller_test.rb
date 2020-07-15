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
      post articulos_url, params: { articulo: { aviso_existencia: @articulo.aviso_existencia, codigo: @articulo.codigo, color: @articulo.color, costo_principal: @articulo.costo_principal, estado: @articulo.estado, existencia: @articulo.existencia, identificador: @articulo.identificador, is_combo: @articulo.is_combo, is_detallable: @articulo.is_detallable, marca_id: @articulo.marca_id, medida: @articulo.medida, medida_alerta: @articulo.medida_alerta, modelo_id: @articulo.modelo_id, nombre: @articulo.nombre, precio_principal: @articulo.precio_principal, suplidor_id: @articulo.suplidor_id, tipo_articulo_id: @articulo.tipo_articulo_id } }, as: :json
    end

    assert_response 201
  end

  test "should show articulo" do
    get articulo_url(@articulo), as: :json
    assert_response :success
  end

  test "should update articulo" do
    patch articulo_url(@articulo), params: { articulo: { aviso_existencia: @articulo.aviso_existencia, codigo: @articulo.codigo, color: @articulo.color, costo_principal: @articulo.costo_principal, estado: @articulo.estado, existencia: @articulo.existencia, identificador: @articulo.identificador, is_combo: @articulo.is_combo, is_detallable: @articulo.is_detallable, marca_id: @articulo.marca_id, medida: @articulo.medida, medida_alerta: @articulo.medida_alerta, modelo_id: @articulo.modelo_id, nombre: @articulo.nombre, precio_principal: @articulo.precio_principal, suplidor_id: @articulo.suplidor_id, tipo_articulo_id: @articulo.tipo_articulo_id } }, as: :json
    assert_response 200
  end

  test "should destroy articulo" do
    assert_difference('Articulo.count', -1) do
      delete articulo_url(@articulo), as: :json
    end

    assert_response 204
  end
end
