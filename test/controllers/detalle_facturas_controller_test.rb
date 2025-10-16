require 'test_helper'

class DetalleFacturasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @detalle_factura = detalle_facturas(:one)
  end

  test "should get index" do
    get detalle_facturas_url, as: :json
    assert_response :success
  end

  test "should create detalle_factura" do
    assert_difference('DetalleFactura.count') do
      post detalle_facturas_url, params: { detalle_factura: { articulo_id: @detalle_factura.articulo_id, cabecera_factura_id: @detalle_factura.cabecera_factura_id, cantidad: @detalle_factura.cantidad, descuento: @detalle_factura.descuento, itbis: @detalle_factura.itbis, total: @detalle_factura.total } }, as: :json
    end

    assert_response 201
  end

  test "should show detalle_factura" do
    get detalle_factura_url(@detalle_factura), as: :json
    assert_response :success
  end

  test "should update detalle_factura" do
    patch detalle_factura_url(@detalle_factura), params: { detalle_factura: { articulo_id: @detalle_factura.articulo_id, cabecera_factura_id: @detalle_factura.cabecera_factura_id, cantidad: @detalle_factura.cantidad, descuento: @detalle_factura.descuento, itbis: @detalle_factura.itbis, total: @detalle_factura.total } }, as: :json
    assert_response 200
  end

  test "should destroy detalle_factura" do
    assert_difference('DetalleFactura.count', -1) do
      delete detalle_factura_url(@detalle_factura), as: :json
    end

    assert_response 204
  end
end
