require 'test_helper'

class HistoricoArticulosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @historico_articulo = historico_articulos(:one)
  end

  test "should get index" do
    get historico_articulos_url, as: :json
    assert_response :success
  end

  test "should create historico_articulo" do
    assert_difference('HistoricoArticulo.count') do
      post historico_articulos_url, params: { historico_articulo: { articulo_id: @historico_articulo.articulo_id, aviso_existencia: @historico_articulo.aviso_existencia, codigo: @historico_articulo.codigo, color: @historico_articulo.color, costo_principal: @historico_articulo.costo_principal, estado: @historico_articulo.estado, existencia: @historico_articulo.existencia, identificador: @historico_articulo.identificador, is_combo: @historico_articulo.is_combo, is_detallable: @historico_articulo.is_detallable, marca_id: @historico_articulo.marca_id, medida: @historico_articulo.medida, medida_alerta: @historico_articulo.medida_alerta, modelo_id: @historico_articulo.modelo_id, nombre: @historico_articulo.nombre, precio_principal: @historico_articulo.precio_principal, suplidor_id: @historico_articulo.suplidor_id, tipo_articulo_id: @historico_articulo.tipo_articulo_id } }, as: :json
    end

    assert_response 201
  end

  test "should show historico_articulo" do
    get historico_articulo_url(@historico_articulo), as: :json
    assert_response :success
  end

  test "should update historico_articulo" do
    patch historico_articulo_url(@historico_articulo), params: { historico_articulo: { articulo_id: @historico_articulo.articulo_id, aviso_existencia: @historico_articulo.aviso_existencia, codigo: @historico_articulo.codigo, color: @historico_articulo.color, costo_principal: @historico_articulo.costo_principal, estado: @historico_articulo.estado, existencia: @historico_articulo.existencia, identificador: @historico_articulo.identificador, is_combo: @historico_articulo.is_combo, is_detallable: @historico_articulo.is_detallable, marca_id: @historico_articulo.marca_id, medida: @historico_articulo.medida, medida_alerta: @historico_articulo.medida_alerta, modelo_id: @historico_articulo.modelo_id, nombre: @historico_articulo.nombre, precio_principal: @historico_articulo.precio_principal, suplidor_id: @historico_articulo.suplidor_id, tipo_articulo_id: @historico_articulo.tipo_articulo_id } }, as: :json
    assert_response 200
  end

  test "should destroy historico_articulo" do
    assert_difference('HistoricoArticulo.count', -1) do
      delete historico_articulo_url(@historico_articulo), as: :json
    end

    assert_response 204
  end
end
