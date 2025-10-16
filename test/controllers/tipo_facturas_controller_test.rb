require 'test_helper'

class TipoFacturasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tipo_factura = tipo_facturas(:one)
  end

  test "should get index" do
    get tipo_facturas_url, as: :json
    assert_response :success
  end

  test "should create tipo_factura" do
    assert_difference('TipoFactura.count') do
      post tipo_facturas_url, params: { tipo_factura: { descripcion: @tipo_factura.descripcion, referencia: @tipo_factura.referencia } }, as: :json
    end

    assert_response 201
  end

  test "should show tipo_factura" do
    get tipo_factura_url(@tipo_factura), as: :json
    assert_response :success
  end

  test "should update tipo_factura" do
    patch tipo_factura_url(@tipo_factura), params: { tipo_factura: { descripcion: @tipo_factura.descripcion, referencia: @tipo_factura.referencia } }, as: :json
    assert_response 200
  end

  test "should destroy tipo_factura" do
    assert_difference('TipoFactura.count', -1) do
      delete tipo_factura_url(@tipo_factura), as: :json
    end

    assert_response 204
  end
end
