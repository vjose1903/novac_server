require 'test_helper'

class DetalleConducesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @detalle_conduce = detalle_conduces(:one)
  end

  test "should get index" do
    get detalle_conduces_url, as: :json
    assert_response :success
  end

  test "should create detalle_conduce" do
    assert_difference('DetalleConduce.count') do
      post detalle_conduces_url, params: { detalle_conduce: { articulo_id: @detalle_conduce.articulo_id, cabecera_conduce_id: @detalle_conduce.cabecera_conduce_id, cantidad: @detalle_conduce.cantidad, detalle_factura_id: @detalle_conduce.detalle_factura_id } }, as: :json
    end

    assert_response 201
  end

  test "should show detalle_conduce" do
    get detalle_conduce_url(@detalle_conduce), as: :json
    assert_response :success
  end

  test "should update detalle_conduce" do
    patch detalle_conduce_url(@detalle_conduce), params: { detalle_conduce: { articulo_id: @detalle_conduce.articulo_id, cabecera_conduce_id: @detalle_conduce.cabecera_conduce_id, cantidad: @detalle_conduce.cantidad, detalle_factura_id: @detalle_conduce.detalle_factura_id } }, as: :json
    assert_response 200
  end

  test "should destroy detalle_conduce" do
    assert_difference('DetalleConduce.count', -1) do
      delete detalle_conduce_url(@detalle_conduce), as: :json
    end

    assert_response 204
  end
end
