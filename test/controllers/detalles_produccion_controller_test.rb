require 'test_helper'

class DetallesProduccionControllerTest < ActionDispatch::IntegrationTest
  setup do
    @detalle_produccion = detalles_produccion(:one)
  end

  test "should get index" do
    get detalles_produccion_url, as: :json
    assert_response :success
  end

  test "should create detalle_produccion" do
    assert_difference('DetalleProduccion.count') do
      post detalles_produccion_url, params: { detalle_produccion: { articulo_id: @detalle_produccion.articulo_id, cantidad: @detalle_produccion.cantidad, cantidad_en_unidades: @detalle_produccion.cantidad_en_unidades, medida: @detalle_produccion.medida, produccion_id: @detalle_produccion.produccion_id } }, as: :json
    end

    assert_response 201
  end

  test "should show detalle_produccion" do
    get detalle_produccion_url(@detalle_produccion), as: :json
    assert_response :success
  end

  test "should update detalle_produccion" do
    patch detalle_produccion_url(@detalle_produccion), params: { detalle_produccion: { articulo_id: @detalle_produccion.articulo_id, cantidad: @detalle_produccion.cantidad, cantidad_en_unidades: @detalle_produccion.cantidad_en_unidades, medida: @detalle_produccion.medida, produccion_id: @detalle_produccion.produccion_id } }, as: :json
    assert_response 200
  end

  test "should destroy detalle_produccion" do
    assert_difference('DetalleProduccion.count', -1) do
      delete detalle_produccion_url(@detalle_produccion), as: :json
    end

    assert_response 204
  end
end
