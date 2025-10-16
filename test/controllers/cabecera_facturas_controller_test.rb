require 'test_helper'

class CabeceraFacturasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cabecera_factura = cabecera_facturas(:one)
  end

  test "should get index" do
    get cabecera_facturas_url, as: :json
    assert_response :success
  end

  test "should create cabecera_factura" do
    assert_difference('CabeceraFactura.count') do
      post cabecera_facturas_url, params: { cabecera_factura: { cliente_id: @cabecera_factura.cliente_id, condicion: @cabecera_factura.condicion, descuento: @cabecera_factura.descuento, estado: @cabecera_factura.estado, fecha_facturacion: @cabecera_factura.fecha_facturacion, fecha_valida: @cabecera_factura.fecha_valida, fecha_vencimiento: @cabecera_factura.fecha_vencimiento, forma_pago: @cabecera_factura.forma_pago, itbis: @cabecera_factura.itbis, numero_comprobante: @cabecera_factura.numero_comprobante, numero_factura: @cabecera_factura.numero_factura, suplidor_id: @cabecera_factura.suplidor_id, tipo: @cabecera_factura.tipo, tipo_factura_id: @cabecera_factura.tipo_factura_id, total_factura: @cabecera_factura.total_factura, user_id: @cabecera_factura.user_id } }, as: :json
    end

    assert_response 201
  end

  test "should show cabecera_factura" do
    get cabecera_factura_url(@cabecera_factura), as: :json
    assert_response :success
  end

  test "should update cabecera_factura" do
    patch cabecera_factura_url(@cabecera_factura), params: { cabecera_factura: { cliente_id: @cabecera_factura.cliente_id, condicion: @cabecera_factura.condicion, descuento: @cabecera_factura.descuento, estado: @cabecera_factura.estado, fecha_facturacion: @cabecera_factura.fecha_facturacion, fecha_valida: @cabecera_factura.fecha_valida, fecha_vencimiento: @cabecera_factura.fecha_vencimiento, forma_pago: @cabecera_factura.forma_pago, itbis: @cabecera_factura.itbis, numero_comprobante: @cabecera_factura.numero_comprobante, numero_factura: @cabecera_factura.numero_factura, suplidor_id: @cabecera_factura.suplidor_id, tipo: @cabecera_factura.tipo, tipo_factura_id: @cabecera_factura.tipo_factura_id, total_factura: @cabecera_factura.total_factura, user_id: @cabecera_factura.user_id } }, as: :json
    assert_response 200
  end

  test "should destroy cabecera_factura" do
    assert_difference('CabeceraFactura.count', -1) do
      delete cabecera_factura_url(@cabecera_factura), as: :json
    end

    assert_response 204
  end
end
