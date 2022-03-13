require "test_helper"

class FacturasAplicadasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @factura_aplicada = facturas_aplicadas(:one)
  end

  test "should get index" do
    get facturas_aplicadas_url, as: :json
    assert_response :success
  end

  test "should create factura_aplicada" do
    assert_difference('FacturaAplicada.count') do
      post facturas_aplicadas_url, params: { factura_aplicada: { cabeza_factura_id: @factura_aplicada.cabeza_factura_id, nota_id: @factura_aplicada.nota_id, total: @factura_aplicada.total } }, as: :json
    end

    assert_response 201
  end

  test "should show factura_aplicada" do
    get factura_aplicada_url(@factura_aplicada), as: :json
    assert_response :success
  end

  test "should update factura_aplicada" do
    patch factura_aplicada_url(@factura_aplicada), params: { factura_aplicada: { cabeza_factura_id: @factura_aplicada.cabeza_factura_id, nota_id: @factura_aplicada.nota_id, total: @factura_aplicada.total } }, as: :json
    assert_response 200
  end

  test "should destroy factura_aplicada" do
    assert_difference('FacturaAplicada.count', -1) do
      delete factura_aplicada_url(@factura_aplicada), as: :json
    end

    assert_response 204
  end
end
