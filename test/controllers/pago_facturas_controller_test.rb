require "test_helper"

class PagoFacturasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @pago_factura = pago_facturas(:one)
  end

  test "should get index" do
    get pago_facturas_url, as: :json
    assert_response :success
  end

  test "should create pago_factura" do
    assert_difference("PagoFactura.count") do
      post pago_facturas_url, params: { pago_factura: { estado: @pago_factura.estado, fecha_equivalente: @pago_factura.fecha_equivalente, forma_pago: @pago_factura.forma_pago, numero: @pago_factura.numero, suplidor_id: @pago_factura.suplidor_id, tipo_factura_id: @pago_factura.tipo_factura_id, total: @pago_factura.total, user_id: @pago_factura.user_id } }, as: :json
    end

    assert_response :created
  end

  test "should show pago_factura" do
    get pago_factura_url(@pago_factura), as: :json
    assert_response :success
  end

  test "should update pago_factura" do
    patch pago_factura_url(@pago_factura), params: { pago_factura: { estado: @pago_factura.estado, fecha_equivalente: @pago_factura.fecha_equivalente, forma_pago: @pago_factura.forma_pago, numero: @pago_factura.numero, suplidor_id: @pago_factura.suplidor_id, tipo_factura_id: @pago_factura.tipo_factura_id, total: @pago_factura.total, user_id: @pago_factura.user_id } }, as: :json
    assert_response :success
  end

  test "should destroy pago_factura" do
    assert_difference("PagoFactura.count", -1) do
      delete pago_factura_url(@pago_factura), as: :json
    end

    assert_response :no_content
  end
end
